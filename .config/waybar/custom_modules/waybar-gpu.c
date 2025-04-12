#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <dirent.h>
#include <math.h>

#define MAX_PATH 256

// Define colors
const char *WARNING_COLOR = "#fab387";
const char *CRITICAL_COLOR = "#f38ba8";

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

// Classification functions
const char *class_temp(float c) {
    return (c < 50) ? "optimal" : (c < 80) ? "moderate" : "critical";
}

const char *class_usage(int u) {
    return (u < 50) ? "optimal" : (u < 85) ? "moderate" : "critical";
}

const char *class_power(float w) {
    return (w < 80) ? "optimal" : (w < 160) ? "moderate" : "critical";
}

const char *class_fan_rpm(int rpm) {
    return (rpm > 2000) ? "critical" : (rpm > 1500) ? "moderate" : "optimal";
}

const char *class_vram_usage(float vram_usage) {
    return (vram_usage > 11.0f) ? "critical" : (vram_usage > 6.0f) ? "moderate" : "optimal";
}

// Return style string or empty for optimal
void get_color_str(const char *class_str, char *out, size_t len) {
    if (strcmp(class_str, "critical") == 0)
        snprintf(out, len, "foreground='%s'", CRITICAL_COLOR);
    else if (strcmp(class_str, "moderate") == 0)
        snprintf(out, len, "foreground='%s'", WARNING_COLOR);
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
        // Read metrics
        float temp_raw = read_scaled(path_temp, 1000.0f);
        int temp = (int)(temp_raw + 0.5f);
        int fan_rpm = read_int(path_fan);
        float power_raw = read_scaled(path_power, 1000000.0f);
        int power = (int)(power_raw + 0.5f);
        int usage = read_int(path_usage);
        unsigned long long vram_used = read_ull(path_vram_used);
        unsigned long long vram_total = read_ull(path_vram_total);
        float vram_gib = (vram_total > 0) ? ((float)vram_used / 1073741824.0f) : 0.0f;

        // Classify
        const char *class_temp_str = class_temp(temp_raw);
        const char *class_usage_str = class_usage(usage);
        const char *class_power_str = class_power(power_raw);
        const char *class_fan_str = class_fan_rpm(fan_rpm);
        const char *class_vram_str = class_vram_usage(vram_gib);

        // Generate color styles
        char temp_fg_str[64], usage_fg_str[64], power_fg_str[64];
        char fan_fg_str[64], vram_fg_str[64];
        get_color_str(class_temp_str, temp_fg_str, sizeof(temp_fg_str));
        get_color_str(class_usage_str, usage_fg_str, sizeof(usage_fg_str));
        get_color_str(class_power_str, power_fg_str, sizeof(power_fg_str));
        get_color_str(class_fan_str, fan_fg_str, sizeof(fan_fg_str));
        get_color_str(class_vram_str, vram_fg_str, sizeof(vram_fg_str));

        // Output formatted JSON
        printf(
            "{\"text\":\""
            "<span %s><big>󰾲</big></span> %d%% "
            "<span %s></span> %d°C "
            "<span %s></span> %.1fG "
            "<span %s><big>󰈐</big></span> %d "
            "<span %s><big>󱐋</big></span>%dW\",",
            usage_fg_str, usage,
            temp_fg_str, temp,
            vram_fg_str, vram_gib,
            fan_fg_str, fan_rpm,
            power_fg_str, power
        );

        // Use temp class as overall severity (or you could compute highest-severity class)
        printf("\"class\":\"%s\"}\n", class_temp_str);
        fflush(stdout);
        sleep(interval);
    }

    return 0;
}
