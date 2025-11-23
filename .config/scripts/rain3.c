/*
 * Terminal Rain and Thunderstorm Simulator
 * Compile: gcc -o rain rain.c -lncurses -lm
 * Usage: ./rain [--rain-color COLOR] [--lightning-color COLOR] [--intensity LEVEL] [--puddles] [--flash] [--totoro]
 * Press 't' for thunderstorm, 'w' for wind, '+/-' for intensity, 'p' for puddles, 'o' for totoro, 'h' for help
 */

#include <ncurses.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <math.h>
#include <unistd.h>
#include <sys/time.h>
#include <locale.h>

// Configuration
#define UPDATE_INTERVAL 0.015
#define RAIN_CHARS "|.`"
#define RAIN_CHAR_COUNT 3
#define COLOR_PAIR_RAIN_NORMAL 1
#define COLOR_PAIR_LIGHTNING 4
#define COLOR_PAIR_THUNDER_FLASH 5
#define LIGHTNING_CHARS "*+#"
#define LIGHTNING_CHAR_COUNT 3
#define LIGHTNING_CHANCE 0.005
#define LIGHTNING_GROWTH_DELAY 0.002
#define LIGHTNING_MAX_BRANCHES 2
#define LIGHTNING_BRANCH_CHANCE 0.3
#define FORK_CHANCE 0.15
#define FORK_HORIZONTAL_SPREAD 3
#define SEGMENT_LIFESPAN 0.8
#define MAX_RAINDROPS 10000
#define MAX_BOLTS 3
#define MAX_SEGMENTS 1000
#define PUDDLE_CHARS "---=="
#define PUDDLE_CHAR_COUNT 5
#define MAX_PUDDLES 200
#define PUDDLE_LIFESPAN 5.0
#define PUDDLE_GROWTH_RATE 0.3
#define THUNDER_FLASH_DURATION 0.05

// Color mapping
typedef struct {
    const char *name;
    int value;
} ColorMap;

static const ColorMap color_map[] = {
    {"black", COLOR_BLACK},
    {"red", COLOR_RED},
    {"green", COLOR_GREEN},
    {"yellow", COLOR_YELLOW},
    {"blue", COLOR_BLUE},
    {"magenta", COLOR_MAGENTA},
    {"cyan", COLOR_CYAN},
    {"white", COLOR_WHITE}
};
#define COLOR_MAP_SIZE 8

// Structures
typedef struct {
    int x;
    float y;
    float speed;
    char ch;
    float wind_offset; // For wind effect
} Raindrop;

typedef struct {
    int y, x;
    double creation_time;
} Segment;

typedef struct {
    int start_col;
    int target_length;
    Segment segments[MAX_SEGMENTS];
    int segment_count;
    double last_growth_time;
    int is_growing;
    int max_y, max_x;
} LightningBolt;

typedef struct {
    int x, y;
    double creation_time;
    float size;
} Puddle;

// Global variables
static Raindrop raindrops[MAX_RAINDROPS];
static int raindrop_count = 0;
static LightningBolt bolts[MAX_BOLTS];
static int bolt_count = 0;
static Puddle puddles[MAX_PUDDLES];
static int puddle_count = 0;
static int lightning_color_attr = 0;
static float wind_strength = 0.0;
static double thunder_flash_time = 0.0;
static float intensity_multiplier = 1.0;
static int show_stats = 0;
static int puddles_enabled = 0;
static int flash_enabled = 0;
static int totoro_enabled = 0;

// Totoro ASCII art (27 lines) - original Braille art
static const char *totoro_art[] = {
    "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡀",
    "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⣤⠔⠒⠒⠒⠈⠻⡑⠒⣲⣦⢤⣄⡀",
    "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⠔⠋⡜⠁⠀⠀⠀⣀⣤⣾⣿⣭⣶⣿⣿⣿⣿⣷⣄⡀",
    "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣴⣥⣤⣬⣴⣶⣶⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⡀",
    "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⢹⢃⠸⡟⠛⠛⠛⡿⠿⡟⢻⢉⣻⠛⠛⠛⠛⠋⠉⠉⠁",
    "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⢯⠴⣷⣖⡠⣶⣷⣾⡗⣾⢈⡟⠀⠀⠀⠀⠀⠀⠀⠀",
    "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣴⠟⠀⠈⠉⠓⠊⠙⠛⡟⠃⠀⠙⢆⠀⠀⠀⠀⠀⠀⠀",
    "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⡾⢫⢪⡝⡆⠀⣤⣤⣤⣤⡇⡴⣭⠱⠀⢳⠀⠀⠀⠀⠀⠀",
    "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠉⠒⢒⠾⠤⢌⠒⠒⠁⠀⠉⠉⠉⠁⡇⠘⠒⠚⡠⠤⢷⠒⠋⠉⠀⠀",
    "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠒⠒⢒⡗⣒⣒⡲⠀⠀⠀⠀⠀⢀⡔⣴⣷⣀⣀⠀⢸⠭⢭⣯⣉⣉⣉⠀",
    "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠁⢉⠏⠉⠀⠀⠀⠀⠀⣀⡠⠤⠤⣿⣿⣿⠂⠀⠉⠉⠑⠢⡜⡄⠀⠀⠀",
    "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⠎⠀⠀⠀⡠⠄⠂⠁⢀⠤⠂⠢⡙⢾⣿⡀⠀⠀⠀⠀⠀⠈⢧⠀⠀⠀",
    "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡜⢀⠆⣠⢊⢴⠭⠦⠀⠉⠉⠉⠁⠁⠈⠀⠱⡀⠀⠀⠀⠀⠀⠈⡇⠀⠀",
    "⠀⠀⠀⠀⠀⢀⣀⠤⡤⢄⣀⣀⠀⠀⠀⠀⠀⡜⠀⡜⡰⠁⠀⠀⠀⢀⣀⠀⠀⠀⡠⠒⢄⠀⠀⢈⠦⣄⠀⠀⠀⠀⢸⠀⠀",
    "⠀⠀⣠⠔⠊⢁⣠⣀⣱⣀⣀⣀⡉⡶⢄⠀⢠⠁⢠⢳⢁⠤⣄⠀⠠⡂⡀⠕⠄⠀⠉⠉⠉⠁⠀⠓⠂⠚⠳⢴⣆⠀⠸⡄⠀",
    "⢀⠞⣸⡶⠛⣿⣿⠟⣽⣿⢙⣿⢺⢽⣮⣧⠘⠀⠸⡌⠚⠉⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⢹⠈⡇⠀",
    "⣯⣾⣿⣧⡶⣉⣶⣦⡞⢹⣿⣿⣾⣾⣿⠟⡇⠀⠐⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⠀⡇⠀",
    "⠙⠻⣿⣿⠹⣾⣇⠀⣿⣞⣿⡿⠿⠟⠁⠀⢡⢀⡆⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⠀⡇⠀",
    "⠀⠀⠈⠈⢿⢸⠙⠛⢻⣽⠀⠀⠀⠀⠀⠀⢨⣿⡇⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣸⠀⡇⠀",
    "⠀⠀⠀⠀⢸⣉⠀⠀⠈⡫⠀⠀⠀⠀⠀⠀⠈⠛⢃⢡⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⠇⢀⠇⠀",
    "⠀⠀⠀⠀⠀⢨⢉⢽⢹⠀⠀⠀⠀⠀⠀⠀⠀⠀⠸⡀⠳⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⠎⠀⡼⠀⠀",
    "⠀⠀⠀⠀⠀⢸⢸⢸⢸⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢣⠀⠘⠦⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⠔⠁⠀⡰⠃⠀⠀",
    "⠀⠀⠀⠀⠀⠸⢾⡾⠾⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠣⡀⠀⠈⢲⢄⡀⠀⠀⠀⠀⠀⠀⠀⢀⡠⠊⠁⠀⠀⡴⠁⠀⠀⠀",
    "⠀⠀⠀⠀⢸⣇⠜⣜⠀⣄⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠙⣢⣴⣧⣴⡈⢩⠒⠤⢤⡤⠔⡊⣕⣧⣀⣀⣠⠊⠀⠀⠀⠀⠀",
    "⠀⠀⠀⠀⠀⠀⠉⠀⠉⠀⠀⠈⠉⠉⠉⠉⠉⠀⠀⠀⠀⠀⠀⠀⠀⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠙⠛⠛⠛⠛⠛⠛⠛⠛⠛",
};

#define TOTORO_LINES 25

// Utility functions
static double get_time(void) {
    struct timeval tv;
    gettimeofday(&tv, NULL);
    return tv.tv_sec + tv.tv_usec / 1000000.0;
}

static float randf(float min, float max) {
    return min + (max - min) * ((float)rand() / RAND_MAX);
}

static int get_color_value(const char *name) {
    for (int i = 0; i < COLOR_MAP_SIZE; i++) {
        if (strcasecmp(name, color_map[i].name) == 0) {
            return color_map[i].value;
        }
    }
    return COLOR_CYAN;
}

static void setup_colors(const char *rain_color, const char *lightning_color) {
    if (has_colors()) {
        start_color();
        int bg = -1;
        if (can_change_color()) {
            use_default_colors();
        } else {
            bg = COLOR_BLACK;
        }
        
        int rain_fg = get_color_value(rain_color);
        int lightning_fg = get_color_value(lightning_color);
        
        init_pair(COLOR_PAIR_RAIN_NORMAL, rain_fg, bg);
        init_pair(COLOR_PAIR_LIGHTNING, lightning_fg, bg);
        init_pair(COLOR_PAIR_THUNDER_FLASH, COLOR_WHITE, COLOR_WHITE);
        lightning_color_attr = COLOR_PAIR(COLOR_PAIR_LIGHTNING) | A_BOLD;
    } else {
        init_pair(COLOR_PAIR_RAIN_NORMAL, COLOR_WHITE, COLOR_BLACK);
        init_pair(COLOR_PAIR_LIGHTNING, COLOR_WHITE, COLOR_BLACK);
        init_pair(COLOR_PAIR_THUNDER_FLASH, COLOR_WHITE, COLOR_WHITE);
        lightning_color_attr = COLOR_PAIR(COLOR_PAIR_LIGHTNING) | A_BOLD;
    }
}

// Lightning functions
static void init_bolt(LightningBolt *bolt, int start_row, int start_col, int max_y, int max_x) {
    bolt->start_col = start_col;
    bolt->target_length = (rand() % (max_y / 2)) + max_y / 2;
    bolt->segment_count = 1;
    bolt->segments[0].y = start_row;
    bolt->segments[0].x = start_col;
    bolt->segments[0].creation_time = get_time();
    bolt->last_growth_time = get_time();
    bolt->is_growing = 1;
    bolt->max_y = max_y;
    bolt->max_x = max_x;
}

static int update_bolt(LightningBolt *bolt) {
    double current_time = get_time();
    
    // Growth phase
    if (bolt->is_growing && (current_time - bolt->last_growth_time >= LIGHTNING_GROWTH_DELAY)) {
        bolt->last_growth_time = current_time;
        int added_segment = 0;
        int initial_count = bolt->segment_count;
        
        if (initial_count > 0) {
            Segment *last = &bolt->segments[initial_count - 1];
            
            if (bolt->segment_count < bolt->target_length && last->y < bolt->max_y - 1) {
                int branches = 1;
                if (randf(0, 1) < LIGHTNING_BRANCH_CHANCE) {
                    branches = (rand() % LIGHTNING_MAX_BRANCHES) + 1;
                }
                
                int current_x = last->x;
                int next_primary_x = current_x;
                
                for (int i = 0; i < branches && bolt->segment_count < MAX_SEGMENTS; i++) {
                    int offset = (rand() % 5) - 2;
                    int next_x = current_x + offset;
                    if (next_x < 0) next_x = 0;
                    if (next_x >= bolt->max_x) next_x = bolt->max_x - 1;
                    
                    int next_y = last->y + 1;
                    if (next_y >= bolt->max_y) next_y = bolt->max_y - 1;
                    
                    bolt->segments[bolt->segment_count].y = next_y;
                    bolt->segments[bolt->segment_count].x = next_x;
                    bolt->segments[bolt->segment_count].creation_time = current_time;
                    bolt->segment_count++;
                    
                    if (i == 0) next_primary_x = next_x;
                    current_x = next_x;
                    added_segment = 1;
                }
                
                // Fork
                if (randf(0, 1) < FORK_CHANCE && bolt->segment_count < MAX_SEGMENTS) {
                    int fork_offset = (rand() % (2 * FORK_HORIZONTAL_SPREAD + 1)) - FORK_HORIZONTAL_SPREAD;
                    if (fork_offset == 0) fork_offset = (rand() % 2) ? 1 : -1;
                    
                    int fork_x = last->x + fork_offset;
                    if (fork_x < 0) fork_x = 0;
                    if (fork_x >= bolt->max_x) fork_x = bolt->max_x - 1;
                    
                    int fork_y = last->y + 1;
                    if (fork_y >= bolt->max_y) fork_y = bolt->max_y - 1;
                    
                    if (fork_x != next_primary_x) {
                        bolt->segments[bolt->segment_count].y = fork_y;
                        bolt->segments[bolt->segment_count].x = fork_x;
                        bolt->segments[bolt->segment_count].creation_time = current_time;
                        bolt->segment_count++;
                        added_segment = 1;
                    }
                }
            }
            
            if (!added_segment || bolt->segment_count >= bolt->target_length || 
                last->y >= bolt->max_y - 1) {
                bolt->is_growing = 0;
            }
        }
    }
    
    // Check if all segments expired
    int all_expired = 1;
    for (int i = 0; i < bolt->segment_count; i++) {
        if ((current_time - bolt->segments[i].creation_time) <= SEGMENT_LIFESPAN) {
            all_expired = 0;
            break;
        }
    }
    
    return !all_expired;
}

static void draw_bolt(LightningBolt *bolt) {
    double current_time = get_time();
    int max_y, max_x;
    getmaxyx(stdscr, max_y, max_x);
    
    for (int i = 0; i < bolt->segment_count; i++) {
        Segment *seg = &bolt->segments[i];
        double segment_age = current_time - seg->creation_time;
        
        if (segment_age <= SEGMENT_LIFESPAN) {
            double norm_age = segment_age / SEGMENT_LIFESPAN;
            char ch;
            
            if (norm_age < 0.33) {
                ch = LIGHTNING_CHARS[2]; // '#'
            } else if (norm_age < 0.66) {
                ch = LIGHTNING_CHARS[1]; // '+'
            } else {
                ch = LIGHTNING_CHARS[0]; // '*'
            }
            
            if (seg->y >= 0 && seg->y < max_y && seg->x >= 0 && seg->x < max_x) {
                mvaddch(seg->y, seg->x, ch | lightning_color_attr);
            }
        }
    }
}

// Main simulation
static void simulate_rain(const char *rain_color, const char *lightning_color) {
    curs_set(0);
    nodelay(stdscr, TRUE);
    timeout(1);
    
    setup_colors(rain_color, lightning_color);
    
    int rows, cols;
    getmaxyx(stdscr, rows, cols);
    int is_thunderstorm = 0;
    double last_update_time = get_time();
    double last_wind_change = get_time();
    
    while (1) {
        int key = getch();
        
        if (key == KEY_RESIZE) {
            getmaxyx(stdscr, rows, cols);
            clear();
            raindrop_count = 0;
            bolt_count = 0;
            puddle_count = 0;
        } else if (key == 'q' || key == 'Q' || key == 27) {
            break;
        } else if (key == 't' || key == 'T') {
            is_thunderstorm = !is_thunderstorm;
            clear();
        } else if (key == 'w' || key == 'W') {
            wind_strength = (wind_strength == 0.0) ? 3.0 : 0.0;
        } else if (key == '+' || key == '=') {
            intensity_multiplier = fminf(3.0, intensity_multiplier + 0.2);
        } else if (key == '-' || key == '_') {
            intensity_multiplier = fmaxf(0.2, intensity_multiplier - 0.2);
        } else if (key == 's' || key == 'S') {
            show_stats = !show_stats;
        } else if (key == 'p' || key == 'P') {
            puddles_enabled = !puddles_enabled;
            if (!puddles_enabled) {
                puddle_count = 0; // Clear puddles when disabled
            }
        } else if (key == 'f' || key == 'F') {
            flash_enabled = !flash_enabled;
        } else if (key == 'o' || key == 'O') {
            totoro_enabled = !totoro_enabled;
        } else if (key == 'h' || key == 'H') {
            clear();
            mvprintw(rows/2 - 6, cols/2 - 20, "=== RAIN SIMULATOR CONTROLS ===");
            mvprintw(rows/2 - 4, cols/2 - 20, "T - Toggle thunderstorm");
            mvprintw(rows/2 - 3, cols/2 - 20, "W - Toggle wind");
            mvprintw(rows/2 - 2, cols/2 - 20, "P - Toggle puddles");
            mvprintw(rows/2 - 1, cols/2 - 20, "F - Toggle flash effect");
            mvprintw(rows/2, cols/2 - 20, "O - Toggle Totoro");
            mvprintw(rows/2 + 1, cols/2 - 20, "+/- - Adjust intensity");
            mvprintw(rows/2 + 2, cols/2 - 20, "S - Toggle stats");
            mvprintw(rows/2 + 3, cols/2 - 20, "H - This help");
            mvprintw(rows/2 + 4, cols/2 - 20, "Q - Quit");
            mvprintw(rows/2 + 6, cols/2 - 20, "Press any key to continue...");
            refresh();
            nodelay(stdscr, FALSE);
            getch();
            nodelay(stdscr, TRUE);
            clear();
        }
        
        // Frame rate control
        double current_time = get_time();
        double delta_time = current_time - last_update_time;
        if (delta_time < UPDATE_INTERVAL) {
            usleep((UPDATE_INTERVAL - delta_time) * 1000000);
        }
        last_update_time = get_time();
        
        // Vary wind strength over time
        if (current_time - last_wind_change > 2.0) {
            if (wind_strength != 0.0) {
                wind_strength = randf(-3.0, 3.0);
            }
            last_wind_change = current_time;
        }
        
        // Update lightning and trigger thunder flash
        if (is_thunderstorm && bolt_count < MAX_BOLTS && 
            randf(0, 1) < LIGHTNING_CHANCE * intensity_multiplier) {
            int start_col = (rand() % (cols / 2)) + cols / 4;
            int start_row = rand() % (rows / 5);
            init_bolt(&bolts[bolt_count], start_row, start_col, rows, cols);
            bolt_count++;
            if (flash_enabled) {
                thunder_flash_time = current_time; // Trigger flash only if enabled
            }
        }
        
        int next_bolt_count = 0;
        for (int i = 0; i < bolt_count; i++) {
            if (update_bolt(&bolts[i])) {
                if (next_bolt_count != i) {
                    bolts[next_bolt_count] = bolts[i];
                }
                next_bolt_count++;
            }
        }
        bolt_count = next_bolt_count;
        
        // Update puddles
        if (puddles_enabled) {
            int next_puddle_count = 0;
            for (int i = 0; i < puddle_count; i++) {
                double age = current_time - puddles[i].creation_time;
                if (age < PUDDLE_LIFESPAN) {
                    puddles[i].size = fminf(3.0, age * PUDDLE_GROWTH_RATE);
                    if (next_puddle_count != i) {
                        puddles[next_puddle_count] = puddles[i];
                    }
                    next_puddle_count++;
                }
            }
            puddle_count = next_puddle_count;
        } else {
            puddle_count = 0;
        }
        
        // Update raindrops
        float generation_chance = (is_thunderstorm ? 0.5 : 0.3) * intensity_multiplier;
        int max_new_drops = (int)((is_thunderstorm ? cols / 8 : cols / 15) * intensity_multiplier);
        float min_speed = 0.3;
        float max_speed = is_thunderstorm ? 1.0 : 0.6;
        
        if (randf(0, 1) < generation_chance && raindrop_count < MAX_RAINDROPS) {
            int num_new_drops = (rand() % max_new_drops) + 1;
            for (int i = 0; i < num_new_drops && raindrop_count < MAX_RAINDROPS; i++) {
                raindrops[raindrop_count].x = rand() % cols;
                raindrops[raindrop_count].y = 0;
                raindrops[raindrop_count].speed = randf(min_speed, max_speed);
                raindrops[raindrop_count].ch = RAIN_CHARS[rand() % RAIN_CHAR_COUNT];
                raindrops[raindrop_count].wind_offset = 0;
                raindrop_count++;
            }
        }
        
        int next_drop_count = 0;
        for (int i = 0; i < raindrop_count; i++) {
            raindrops[i].y += raindrops[i].speed;
            raindrops[i].wind_offset += wind_strength * raindrops[i].speed * 0.05;
            
            int final_x = (int)(raindrops[i].x + raindrops[i].wind_offset);
            int final_y = (int)raindrops[i].y;
            
            // Create puddle when raindrop hits ground (only if puddles enabled and at actual bottom)
            if (puddles_enabled && final_y >= rows - 1 && puddle_count < MAX_PUDDLES && rand() % 10 == 0) {
                puddles[puddle_count].x = final_x;
                puddles[puddle_count].y = rows - 1;
                puddles[puddle_count].creation_time = current_time;
                puddles[puddle_count].size = 0.5;
                puddle_count++;
            }
            
            // Keep raindrop alive as long as it hasn't gone past the bottom of the screen
            if (final_y < rows) {
                if (next_drop_count != i) {
                    raindrops[next_drop_count] = raindrops[i];
                }
                next_drop_count++;
            }
        }
        raindrop_count = next_drop_count;
        
        // Draw
        erase();
        
        // Thunder flash effect
        if (flash_enabled && current_time - thunder_flash_time < THUNDER_FLASH_DURATION) {
            bkgd(COLOR_PAIR(COLOR_PAIR_THUNDER_FLASH));
        } else {
            bkgd(COLOR_PAIR(0));
        }
        
        // Draw puddles first (background)
        if (puddles_enabled) {
            for (int i = 0; i < puddle_count; i++) {
                int size = (int)puddles[i].size;
                for (int dx = -size; dx <= size; dx++) {
                    int px = puddles[i].x + dx;
                    if (px >= 0 && px < cols && puddles[i].y >= 0 && puddles[i].y < rows) {
                        // Use '-' for small puddles, '=' for larger puddles
                        char ch = (size < 2) ? '-' : '=';
                        int attr = COLOR_PAIR(COLOR_PAIR_RAIN_NORMAL) | A_DIM;
                        mvaddch(puddles[i].y, px, ch | attr);
                    }
                }
            }
        }
        
        // Draw lightning
        for (int i = 0; i < bolt_count; i++) {
            draw_bolt(&bolts[i]);
        }
        
        // Draw raindrops
        for (int i = 0; i < raindrop_count; i++) {
            int y = (int)raindrops[i].y;
            int x = (int)(raindrops[i].x + raindrops[i].wind_offset);
            
            if (y >= 0 && y < rows && x >= 0 && x < cols) {
                int attr = COLOR_PAIR(COLOR_PAIR_RAIN_NORMAL);
                if (is_thunderstorm) {
                    attr |= A_BOLD;
                } else if (raindrops[i].speed < 0.8) {
                    attr |= A_DIM;
                }
                mvaddch(y, x, raindrops[i].ch | attr);
            }
        }
        
        // Draw Totoro at the bottom (drawn last so it appears on top of rain)
        if (totoro_enabled) {
            int totoro_start_row = rows - TOTORO_LINES;
            if (totoro_start_row >= 0) {
                for (int i = 0; i < TOTORO_LINES; i++) {
                    int row = totoro_start_row + i;
                    if (row >= 0 && row < rows) {
                        // Center the Totoro art - Braille characters are typically 1 cell wide
                        const char *line = totoro_art[i];
                        
                        // Count UTF-8 characters (Braille chars are 3 bytes each)
                        int char_count = 0;
                        for (const char *p = line; *p; ) {
                            if ((*p & 0x80) == 0) {
                                p++; // ASCII
                                char_count++;
                            } else if ((*p & 0xE0) == 0xC0) {
                                p += 2; // 2-byte UTF-8
                                char_count++;
                            } else if ((*p & 0xF0) == 0xE0) {
                                p += 3; // 3-byte UTF-8 (Braille)
                                char_count++;
                            } else {
                                p++;
                            }
                        }
                        
                        int start_col = (cols - char_count) / 2;
                        if (start_col < 0) start_col = 0;
                        
                        move(row, start_col);
                        addstr(line);
                    }
                }
            }
        }
        
        // Draw stats
        if (show_stats) {
            mvprintw(0, 0, "Drops:%d Bolts:%d Puddles:%d | Wind:%.1f Int:%.1fx | Puddles:%s Flash:%s Totoro:%s | [H]elp", 
                     raindrop_count, bolt_count, puddle_count, wind_strength, intensity_multiplier,
                     puddles_enabled ? "ON" : "OFF", flash_enabled ? "ON" : "OFF", totoro_enabled ? "ON" : "OFF");
        }
        
        refresh();
    }
}

int main(int argc, char *argv[]) {
    // Check for TTY
    if (!isatty(STDOUT_FILENO)) {
        fprintf(stderr, "Error: This script requires a TTY with curses support.\n");
        return 1;
    }
    
    // Set locale for UTF-8 support (needed for Braille characters)
    setlocale(LC_ALL, "");
    
    // Parse arguments
    const char *rain_color = "cyan";
    const char *lightning_color = "yellow";
    
    for (int i = 1; i < argc; i++) {
        if (strcmp(argv[i], "--rain-color") == 0 && i + 1 < argc) {
            rain_color = argv[++i];
        } else if (strcmp(argv[i], "--lightning-color") == 0 && i + 1 < argc) {
            lightning_color = argv[++i];
        } else if (strcmp(argv[i], "--intensity") == 0 && i + 1 < argc) {
            intensity_multiplier = atof(argv[++i]);
            if (intensity_multiplier < 0.1) intensity_multiplier = 0.1;
            if (intensity_multiplier > 5.0) intensity_multiplier = 5.0;
        } else if (strcmp(argv[i], "--puddles") == 0) {
            puddles_enabled = 1;
        } else if (strcmp(argv[i], "--flash") == 0) {
            flash_enabled = 1;
        } else if (strcmp(argv[i], "--totoro") == 0) {
            totoro_enabled = 1;
        } else if (strcmp(argv[i], "--help") == 0 || strcmp(argv[i], "-h") == 0) {
            printf("Usage: %s [OPTIONS]\n", argv[0]);
            printf("\nOptions:\n");
            printf("  --rain-color COLOR       Set rain color (default: cyan)\n");
            printf("  --lightning-color COLOR  Set lightning color (default: yellow)\n");
            printf("  --intensity LEVEL        Set intensity (0.1-5.0, default: 1.0)\n");
            printf("  --puddles                Enable puddles (default: off)\n");
            printf("  --flash                  Enable thunder flash effect (default: off)\n");
            printf("  --totoro                 Show Totoro at bottom (default: off)\n");
            printf("\nColors: black, red, green, yellow, blue, magenta, cyan, white\n");
            printf("\nControls:\n");
            printf("  t - Toggle thunderstorm\n");
            printf("  w - Toggle wind effect\n");
            printf("  p - Toggle puddles\n");
            printf("  f - Toggle flash effect\n");
            printf("  o - Toggle Totoro\n");
            printf("  +/- - Adjust intensity\n");
            printf("  s - Toggle stats display\n");
            printf("  h - Show help\n");
            printf("  q - Quit\n");
            return 0;
        }
    }
    
    srand(time(NULL));
    
    initscr();
    simulate_rain(rain_color, lightning_color);
    endwin();
    
    return 0;
}