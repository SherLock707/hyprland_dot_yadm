#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <unistd.h>
#include <pwd.h>

typedef struct {
    double r, g, b;
} RGB;

typedef struct {
    double h, s, v;
} HSV;

static RGB hex_to_rgb(const char *hex) {
    RGB color;
    if (hex[0] == '#') hex++;
    unsigned int r, g, b;
    sscanf(hex, "%02x%02x%02x", &r, &g, &b);
    color.r = r / 255.0;
    color.g = g / 255.0;
    color.b = b / 255.0;
    return color;
}

static HSV rgb_to_hsv(RGB rgb) {
    HSV hsv;
    double max = fmax(rgb.r, fmax(rgb.g, rgb.b));
    double min = fmin(rgb.r, fmin(rgb.g, rgb.b));
    double delta = max - min;

    if (delta == 0)
        hsv.h = 0;
    else if (max == rgb.r)
        hsv.h = 60 * fmod(((rgb.g - rgb.b) / delta), 6);
    else if (max == rgb.g)
        hsv.h = 60 * (((rgb.b - rgb.r) / delta) + 2);
    else
        hsv.h = 60 * (((rgb.r - rgb.g) / delta) + 4);

    if (hsv.h < 0) hsv.h += 360;
    hsv.s = (max == 0) ? 0 : delta / max;
    hsv.v = max;
    return hsv;
}

static RGB hsv_to_rgb(HSV hsv) {
    double c = hsv.v * hsv.s;
    double x = c * (1 - fabs(fmod(hsv.h / 60.0, 2) - 1));
    double m = hsv.v - c;
    double r, g, b;

    if (hsv.h < 60) { r = c; g = x; b = 0; }
    else if (hsv.h < 120) { r = x; g = c; b = 0; }
    else if (hsv.h < 180) { r = 0; g = c; b = x; }
    else if (hsv.h < 240) { r = 0; g = x; b = c; }
    else if (hsv.h < 300) { r = x; g = 0; b = c; }
    else { r = c; g = 0; b = x; }

    RGB rgb = { (r + m), (g + m), (b + m) };
    return rgb;
}

static void rgb_to_hex(RGB rgb, char *out) {
    sprintf(out, "#%02x%02x%02x",
            (int)round(rgb.r * 255),
            (int)round(rgb.g * 255),
            (int)round(rgb.b * 255));
}

static char *expand_tilde(const char *path) {
    if (path[0] != '~')
        return strdup(path);
    const char *home = getenv("HOME");
    if (!home) home = getpwuid(getuid())->pw_dir;
    char *expanded = malloc(strlen(home) + strlen(path));
    sprintf(expanded, "%s%s", home, path + 1);
    return expanded;
}

int main(int argc, char **argv) {
    if (argc != 3) {
        fprintf(stderr, "Usage: %s <hex_color> <output_file>\n", argv[0]);
        return 1;
    }

    RGB base_rgb = hex_to_rgb(argv[1]);
    HSV base_hsv = rgb_to_hsv(base_rgb);
    char *outpath = expand_tilde(argv[2]);
    FILE *f = fopen(outpath, "w");
    if (!f) {
        perror("Error opening file");
        free(outpath);
        return 1;
    }

    fprintf(f, "[color]\n\n");
    fprintf(f, "gradient = 1\n");

    // gradient_color_* now varies SATURATION, reversed order (light → dark)
    for (int i = 1; i <= 8; i++) {
        HSV hsv = base_hsv;
        double step = 0.1;
        // Reverse order: 1 = lightest (less saturation), 8 = most saturated
        int offset = 4 - i;
        hsv.s = fmin(fmax(base_hsv.s + offset * step, 0.0), 1.0);
        RGB rgb = hsv_to_rgb(hsv);
        char hex[8];
        rgb_to_hex(rgb, hex);
        fprintf(f, "gradient_color_%d = '%s'\n", i, hex);
    }

    fprintf(f, "\n\nhorizontal_gradient = 1\n");

    // horizontal_gradient_color_* varies VALUE (lightness), normal order (dark → light)
    for (int i = 1; i <= 8; i++) {
        HSV hsv = base_hsv;
        double step = 0.1;
        int offset = i - 4;
        hsv.v = fmin(fmax(base_hsv.v + offset * step, 0.0), 1.0);
        RGB rgb = hsv_to_rgb(hsv);
        char hex[8];
        rgb_to_hex(rgb, hex);
        fprintf(f, "horizontal_gradient_color_%d = '%s'\n", i, hex);
    }

    fclose(f);
    free(outpath);
    return 0;
}



// gcc -Ofast -o cava_color_blend cava_color_blend.c -lm
//./cava_color_blend '#d2a39f' '~/.config/cava/themes/adaptive_colors