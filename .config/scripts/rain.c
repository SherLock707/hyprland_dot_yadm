/*
 * Terminal Rain and Thunderstorm Simulator
 * Compile: gcc -o rain rain.c -lncurses -lm
 * Usage: ./rain [--rain-color COLOR] [--lightning-color COLOR]
 */

#include <ncurses.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <math.h>
#include <unistd.h>
#include <sys/time.h>

// Configuration
#define UPDATE_INTERVAL 0.015
#define RAIN_CHARS "|.`"
#define RAIN_CHAR_COUNT 3
#define COLOR_PAIR_RAIN_NORMAL 1
#define COLOR_PAIR_LIGHTNING 4
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

// Global variables
static Raindrop raindrops[MAX_RAINDROPS];
static int raindrop_count = 0;
static LightningBolt bolts[MAX_BOLTS];
static int bolt_count = 0;
static int lightning_color_attr = 0;

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
        lightning_color_attr = COLOR_PAIR(COLOR_PAIR_LIGHTNING) | A_BOLD;
    } else {
        init_pair(COLOR_PAIR_RAIN_NORMAL, COLOR_WHITE, COLOR_BLACK);
        init_pair(COLOR_PAIR_LIGHTNING, COLOR_WHITE, COLOR_BLACK);
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
    
    while (1) {
        int key = getch();
        
        if (key == KEY_RESIZE) {
            getmaxyx(stdscr, rows, cols);
            clear();
            raindrop_count = 0;
            bolt_count = 0;
        } else if (key == 'q' || key == 'Q' || key == 27) {
            break;
        } else if (key == 't' || key == 'T') {
            is_thunderstorm = !is_thunderstorm;
            clear();
        }
        
        // Frame rate control
        double current_time = get_time();
        double delta_time = current_time - last_update_time;
        if (delta_time < UPDATE_INTERVAL) {
            usleep((UPDATE_INTERVAL - delta_time) * 1000000);
        }
        last_update_time = get_time();
        
        // Update lightning
        if (is_thunderstorm && bolt_count < MAX_BOLTS && randf(0, 1) < LIGHTNING_CHANCE) {
            int start_col = (rand() % (cols / 2)) + cols / 4;
            int start_row = rand() % (rows / 5);
            init_bolt(&bolts[bolt_count], start_row, start_col, rows, cols);
            bolt_count++;
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
        
        // Update raindrops
        float generation_chance = is_thunderstorm ? 0.5 : 0.3;
        int max_new_drops = is_thunderstorm ? cols / 8 : cols / 15;
        float min_speed = 0.3;
        float max_speed = is_thunderstorm ? 1.0 : 0.6;
        
        if (randf(0, 1) < generation_chance && raindrop_count < MAX_RAINDROPS) {
            int num_new_drops = (rand() % max_new_drops) + 1;
            for (int i = 0; i < num_new_drops && raindrop_count < MAX_RAINDROPS; i++) {
                raindrops[raindrop_count].x = rand() % cols;
                raindrops[raindrop_count].y = 0;
                raindrops[raindrop_count].speed = randf(min_speed, max_speed);
                raindrops[raindrop_count].ch = RAIN_CHARS[rand() % RAIN_CHAR_COUNT];
                raindrop_count++;
            }
        }
        
        int next_drop_count = 0;
        for (int i = 0; i < raindrop_count; i++) {
            raindrops[i].y += raindrops[i].speed;
            if ((int)raindrops[i].y < rows) {
                if (next_drop_count != i) {
                    raindrops[next_drop_count] = raindrops[i];
                }
                next_drop_count++;
            }
        }
        raindrop_count = next_drop_count;
        
        // Draw
        erase();
        
        for (int i = 0; i < bolt_count; i++) {
            draw_bolt(&bolts[i]);
        }
        
        for (int i = 0; i < raindrop_count; i++) {
            int y = (int)raindrops[i].y;
            int x = raindrops[i].x;
            
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
        
        refresh();
    }
}

int main(int argc, char *argv[]) {
    // Check for TTY
    if (!isatty(STDOUT_FILENO)) {
        fprintf(stderr, "Error: This script requires a TTY with curses support.\n");
        return 1;
    }
    
    // Parse arguments
    const char *rain_color = "cyan";
    const char *lightning_color = "yellow";
    
    for (int i = 1; i < argc; i++) {
        if (strcmp(argv[i], "--rain-color") == 0 && i + 1 < argc) {
            rain_color = argv[++i];
        } else if (strcmp(argv[i], "--lightning-color") == 0 && i + 1 < argc) {
            lightning_color = argv[++i];
        } else if (strcmp(argv[i], "--help") == 0 || strcmp(argv[i], "-h") == 0) {
            printf("Usage: %s [--rain-color COLOR] [--lightning-color COLOR]\n", argv[0]);
            printf("Colors: black, red, green, yellow, blue, magenta, cyan, white\n");
            printf("Press 't' to toggle thunderstorm, 'q' to quit\n");
            return 0;
        }
    }
    
    srand(time(NULL));
    
    initscr();
    simulate_rain(rain_color, lightning_color);
    endwin();
    
    return 0;
}

// gcc -o rain rain.c -lncurses -lm -O3
// ./rain --rain-color cyan --lightning-color yellow