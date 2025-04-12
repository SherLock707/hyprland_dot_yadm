#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <dirent.h>
#include <math.h>

#define MAX_PATH 256

// Define colors
#define WARNING_COLOR "#fab387"
#define CRITICAL_COLOR "#f38ba8"
#define OPTIMAL_COLOR ""

// Read integer from a sysfs file
int read_int(const char *path) {
    FILE *fp = fopen(path, "r");
    if (!fp) return -1;
    int val;
    if (fscanf(fp, "%d", &val) != 1) val = -1;
    fclose(fp);
    return val;
}

// Read unsigned long long from a sysfs file
unsigned long long read_ull(const char *path) {
    FILE *fp = fopen(path, "r");
    if (!fp) return 0;
    unsigned long long val = 0;
    if (fscanf(fp, "%llu", &val) != 1) val = 0;
    fclose(fp);
    return val;
}

// Read float from a sysfs file, dividing by a factor
float read_scaled(const char *path, float divisor) {
    int val = read_int(path);
    return (val >= 0) ? val / divisor : -1.0f;
}

// Find hwmonX path for amdgpu
int find_amdgpu_hwmon(char *out_path, size_t len) {
    for (int i = 0; i < 20; ++i) {
        char name_path[MAX_PATH];
        snprintf(name_path, sizeof(name_path), "/sys/class/hwmon/hwmon%d/name", i);
        FILE *fp = fopen(name_path, "r");
        if (!fp) continue;
        char name[32];
        if (fscanf(fp, "%31s", name) == 1 && strcmp(name, "amdgpu") == 0) {
            snprintf(out_path, len, "/sys/class/hwmon/hwmon%d", i);
            fclose(fp);
            return 0;
        }
        fclose(fp);
    }
    strncpy(out_path, "/sys/class/hwmon/hwmon5", len);
    return -1;
}

// Classification for different parameters
const char *class_temp(float c)        { return (c < 50) ? "optimal" : (c < 80) ? "moderate" : "critical"; }
const char *class_usage(int u)         { return (u < 50) ? "optimal" : (u < 85) ? "moderate" : "critical"; }
const char *class_power(float w)       { return (w < 80) ? "optimal" : (w < 160) ? "moderate" : "critical"; }
const char *class_fan_rpm(int rpm)     { return (rpm > 2000) ? "critical" : (rpm > 1500) ? "moderate" : "optimal"; }
const char *class_vram_usage(float v)  { return (v > 11.0f) ? "critical" : (v > 6.0f) ? "moderate" : "optimal"; }

// Helper: Map classification to foreground color string
const char *class_to_color(const char *class) {
    if (*class == 'c') return CRITICAL_COLOR;
    if (*class == 'm') return WARNING_COLOR;
    return OPTIMAL_COLOR;
}

// Helper: Set span string if needed
void build_color_span(char *out, size_t size, const char *class) {
    const char *color = class_to_color(class);
    if (*color)
        snprintf(out, size, "foreground='%s'", color);
    else
        out[0] = '\0';
}

int main(int argc, char **argv) {
    int interval = (argc > 1) ? atoi(argv[1]) : 5;

    char hwmon_path[MAX_PATH];
    find_amdgpu_hwmon(hwmon_path, sizeof(hwmon_path));

    char path_temp[MAX_PATH], path_fan[MAX_PATH], path_power[MAX_PATH];
    char path_usage[MAX_PATH], path_vram_used[MAX_PATH], path_vram_total[MAX_PATH];

    snprintf(path_temp, sizeof(path_temp), "%s/temp1_input", hwmon_path);
    snprintf(path_fan, sizeof(path_fan), "%s/fan1_input", hwmon_path);
    snprintf(path_power, sizeof(path_power), "%s/power1_average", hwmon_path);

    snprintf(path_usage, sizeof(path_usage), "%s/device/gpu_busy_percent", hwmon_path);
    snprintf(path_vram_used, sizeof(path_vram_used), "%s/device/mem_info_vram_used", hwmon_path);
    snprintf(path_vram_total, sizeof(path_vram_total), "%s/device/mem_info_vram_total", hwmon_path);

    while (1) {
        char temp_fg[64], usage_fg[64], power_fg[64], fan_fg[64], vram_fg[64];

        float temp_raw = read_scaled(path_temp, 1000.0f);
        int temp = (int)(temp_raw + 0.5f);
        int fan_rpm = read_int(path_fan);
        float power_raw = read_scaled(path_power, 1000000.0f);
        int power = (int)(power_raw + 0.5f);
        int usage = read_int(path_usage);
        unsigned long long vram_used = read_ull(path_vram_used);
        unsigned long long vram_total = read_ull(path_vram_total);
        float vram_gib = (vram_total > 0) ? ((float)vram_used / 1073741824.0f) : 0.0f;

        const char *class_temp_str = class_temp(temp_raw);
        const char *class_usage_str = class_usage(usage);
        const char *class_power_str = class_power(power_raw);
        const char *class_fan_str = class_fan_rpm(fan_rpm);
        const char *class_vram_str = class_vram_usage(vram_gib);

        build_color_span(temp_fg, sizeof(temp_fg), class_temp_str);
        build_color_span(usage_fg, sizeof(usage_fg), class_usage_str);
        build_color_span(power_fg, sizeof(power_fg), class_power_str);
        build_color_span(fan_fg, sizeof(fan_fg), class_fan_str);
        build_color_span(vram_fg, sizeof(vram_fg), class_vram_str);

        printf("{\"text\":\"<span %s><big>󰾲</big></span> %d%% <span %s></span> %d°C <span %s></span> %.1fG <span %s><big>󰈐</big></span> %d <span %s><big>󱐋</big></span>%dW\",",
                usage_fg, usage, temp_fg, temp, vram_fg, vram_gib, fan_fg, fan_rpm, power_fg, power);

        printf("\"class\":\"%s\"}\n", class_temp_str);
        fflush(stdout);

        // Sleep before updating again
        sleep(interval);
    }

    return 0;
}
