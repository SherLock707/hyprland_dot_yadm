/*
 * cursor-ring — Wayland cursor finder overlay (DEBUG BUILD)
 *
 * Build:
 *   gcc $(pkg-config --cflags --libs gtk4 gtk4-layer-shell-0) -lm -O0 -g -o cursor-ring main.c
 */

#include <gtk/gtk.h>
#include <gtk4-layer-shell/gtk4-layer-shell.h>
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define DBG(...) do { fprintf(stderr, "[DBG] " __VA_ARGS__); fflush(stderr); } while(0)

/* ─── Defaults ───────────────────────────────────────────────────────────── */

#define DEFAULT_X            -1
#define DEFAULT_Y            -1
#define DEFAULT_RINGS        1
#define DEFAULT_RADIUS       80.0
#define DEFAULT_DURATION     600
#define DEFAULT_LINE_WIDTH   3.0
#define DEFAULT_COLOR_R      1.0
#define DEFAULT_COLOR_G      0.2
#define DEFAULT_COLOR_B      0.2
#define DEFAULT_COLOR_A      1.0
#define RING2_DELAY_FRAC     0.25
#define WINDOW_PADDING       20

typedef struct {
    int    cursor_x, cursor_y;
    int    rings;
    double radius;
    int    duration_ms;
    double line_width;
    double r, g, b, a;
} Config;

typedef struct {
    GtkWindow      *window;
    GtkDrawingArea *canvas;
    GApplication   *app;        /* held reference to keep main loop alive */
    Config          cfg;
    gint64          start_us;
    gboolean        started;
    int             frame_count;
} AppState;

/* ─── Drawing ────────────────────────────────────────────────────────────── */

static void
draw_ring (cairo_t *cr, double cx, double cy, const Config *cfg, double progress)
{
    double radius = cfg->radius * (1.0 - progress);
    double alpha  = cfg->a     * (1.0 - progress);

    DBG("  draw_ring: progress=%.3f radius=%.1f alpha=%.3f\n", progress, radius, alpha);

    if (radius < 0.5 || alpha < 0.01) {
        DBG("  draw_ring: SKIPPED (too small)\n");
        return;
    }

    cairo_set_line_width (cr, cfg->line_width);
    cairo_set_source_rgba (cr, cfg->r, cfg->g, cfg->b, alpha);
    cairo_arc (cr, cx, cy, radius, 0.0, 2.0 * G_PI);
    cairo_stroke (cr);
    DBG("  draw_ring: stroked at (%.1f,%.1f) r=%.1f color=(%.2f,%.2f,%.2f,%.2f)\n",
        cx, cy, radius, cfg->r, cfg->g, cfg->b, alpha);
}

static void
on_draw (GtkDrawingArea *area, cairo_t *cr, int width, int height, gpointer user_data)
{
    AppState *state = user_data;
    (void) area;

    state->frame_count++;

    cairo_set_operator (cr, CAIRO_OPERATOR_SOURCE);
    cairo_set_source_rgba (cr, 0.0, 0.0, 0.0, 0.0);
    cairo_paint (cr);
    cairo_set_operator (cr, CAIRO_OPERATOR_OVER);

    if (!state->started) {
        if (state->frame_count <= 3)
            DBG("on_draw: frame %d — not started yet\n", state->frame_count);
        return;
    }

    gint64 now_us  = g_get_monotonic_time ();
    double elapsed = (double)(now_us - state->start_us) / 1000.0;
    double dur     = (double) state->cfg.duration_ms;

    /* Log first 5 frames and every 30 after */
    if (state->frame_count <= 5 || state->frame_count % 30 == 0)
        DBG("on_draw: frame=%d elapsed=%.1fms dur=%.1fms canvas=%dx%d\n",
            state->frame_count, elapsed, dur, width, height);

    double p1 = CLAMP (elapsed / dur, 0.0, 1.0);
    draw_ring (cr, width / 2.0, height / 2.0, &state->cfg, p1);

    if (state->cfg.rings >= 2) {
        double delay = dur * RING2_DELAY_FRAC;
        double p2    = CLAMP ((elapsed - delay) / dur, 0.0, 1.0);
        if (elapsed >= delay)
            draw_ring (cr, width / 2.0, height / 2.0, &state->cfg, p2);
    }

    double last_start = (state->cfg.rings >= 2) ? dur * RING2_DELAY_FRAC : 0.0;
    if (elapsed >= last_start + dur) {
        DBG("on_draw: animation done at frame %d — destroying window\n", state->frame_count);
        GtkWindow *win = state->window;
        g_idle_add_once ((GSourceOnceFunc) gtk_window_destroy, win);
    }
}

/* ─── Tick + signals ─────────────────────────────────────────────────────── */

static gboolean
on_tick (GtkWidget *widget, GdkFrameClock *clock, gpointer user_data)
{
    AppState *state = user_data;
    (void) clock;
    if (!state->started) return G_SOURCE_CONTINUE;
    gtk_widget_queue_draw (widget);
    return G_SOURCE_CONTINUE;
}

static void
on_map (GtkWidget *widget, gpointer user_data)
{
    AppState *state = user_data;
    (void) widget;
    state->start_us = g_get_monotonic_time ();
    state->started  = TRUE;
    DBG("on_map: WINDOW MAPPED — animation clock started\n");
    DBG("on_map: cursor=(%d,%d) radius=%.0f dur=%dms rings=%d color=(%.2f,%.2f,%.2f,%.2f)\n",
        state->cfg.cursor_x, state->cfg.cursor_y,
        state->cfg.radius, state->cfg.duration_ms, state->cfg.rings,
        state->cfg.r, state->cfg.g, state->cfg.b, state->cfg.a);
}

static void on_realize (GtkWidget *widget, gpointer ud) {
    (void)ud;
    DBG("on_realize fired\n");
    GdkSurface *surf = gtk_native_get_surface (GTK_NATIVE (gtk_widget_get_root (widget)));
    DBG("on_realize: GdkSurface = %p\n", (void*)surf);
}

static void on_show    (GtkWidget *w, gpointer ud) { (void)w;(void)ud; DBG("on_show fired\n"); }
static void on_unmap   (GtkWidget *w, gpointer ud) { (void)w;(void)ud; DBG("on_unmap fired\n"); }
static void on_destroy (GtkWidget *w, gpointer user_data) {
    (void)w;
    AppState *state = (AppState *) user_data;
    DBG("on_destroy: releasing app hold — process will exit\n");
    g_application_release (state->app);
}

/* ─── Window setup ───────────────────────────────────────────────────────── */

static void
setup_window (AppState *state, GdkDisplay *display)
{
    Config *cfg = &state->cfg;
    int win_size = (int)(cfg->radius * 2.0) + WINDOW_PADDING * 2;

    DBG("setup_window: win_size=%d\n", win_size);
    DBG("setup_window: display type = %s\n", G_OBJECT_TYPE_NAME(display));

    if (!gtk_layer_is_supported ()) {
        fprintf(stderr, "[FATAL] wlr-layer-shell not supported by compositor!\n");
        fprintf(stderr, "        Are you running a wlroots compositor (Hyprland/Sway/River)?\n");
        exit(1);
    }
    DBG("setup_window: wlr-layer-shell supported\n");

    GtkWidget *window = gtk_window_new ();
    state->window = GTK_WINDOW (window);

    gtk_window_set_decorated   (GTK_WINDOW (window), FALSE);
    gtk_window_set_default_size(GTK_WINDOW (window), win_size, win_size);
    gtk_widget_set_opacity     (window, 1.0);

    /* Force fully transparent background — without this GTK paints a solid colour */
    GtkCssProvider *css = gtk_css_provider_new ();
    gtk_css_provider_load_from_string (css,
        "window, .background { background: transparent; }"
        "* { background: transparent; box-shadow: none; }");
    gtk_style_context_add_provider_for_display (
        gdk_display_get_default (),
        GTK_STYLE_PROVIDER (css),
        GTK_STYLE_PROVIDER_PRIORITY_APPLICATION);
    g_object_unref (css);
    DBG("setup_window: transparent CSS applied\n");

    gtk_layer_init_for_window    (GTK_WINDOW (window));
    gtk_layer_set_layer          (GTK_WINDOW (window), GTK_LAYER_SHELL_LAYER_OVERLAY);
    gtk_layer_set_keyboard_mode  (GTK_WINDOW (window), GTK_LAYER_SHELL_KEYBOARD_MODE_NONE);
    gtk_layer_set_exclusive_zone (GTK_WINDOW (window), 0);

    int wx = cfg->cursor_x - win_size / 2;
    int wy = cfg->cursor_y - win_size / 2;
    DBG("setup_window: anchoring top-left, margin=(%d,%d)\n", wx, wy);

    gtk_layer_set_anchor (GTK_WINDOW (window), GTK_LAYER_SHELL_EDGE_LEFT,   TRUE);
    gtk_layer_set_anchor (GTK_WINDOW (window), GTK_LAYER_SHELL_EDGE_TOP,    TRUE);
    gtk_layer_set_anchor (GTK_WINDOW (window), GTK_LAYER_SHELL_EDGE_RIGHT,  FALSE);
    gtk_layer_set_anchor (GTK_WINDOW (window), GTK_LAYER_SHELL_EDGE_BOTTOM, FALSE);
    gtk_layer_set_margin (GTK_WINDOW (window), GTK_LAYER_SHELL_EDGE_LEFT,   wx);
    gtk_layer_set_margin (GTK_WINDOW (window), GTK_LAYER_SHELL_EDGE_TOP,    wy);

    GtkWidget *canvas = gtk_drawing_area_new ();
    state->canvas = GTK_DRAWING_AREA (canvas);
    gtk_drawing_area_set_draw_func (GTK_DRAWING_AREA (canvas), on_draw, state, NULL);
    gtk_window_set_child (GTK_WINDOW (window), canvas);

    gtk_widget_set_can_target (window, FALSE);
    gtk_widget_set_can_focus  (window, FALSE);
    gtk_widget_set_focusable  (window, FALSE);

    g_signal_connect (window, "map",     G_CALLBACK (on_map),     state);
    g_signal_connect (window, "unmap",   G_CALLBACK (on_unmap),   state);
    g_signal_connect (window, "show",    G_CALLBACK (on_show),    state);
    g_signal_connect (window, "realize", G_CALLBACK (on_realize), state);
    g_signal_connect (window, "destroy", G_CALLBACK (on_destroy), state);

    gtk_widget_add_tick_callback (canvas, on_tick, state, NULL);

    DBG("setup_window: calling gtk_window_present\n");
    gtk_window_present (GTK_WINDOW (window));
    DBG("setup_window: gtk_window_present returned\n");

    (void) display;
}

/* ─── Cursor auto-detection ──────────────────────────────────────────────── */

static gboolean
run_command (const char *cmd, char *buf, size_t bufsz)
{
    FILE *fp = popen (cmd, "r");
    if (!fp) return FALSE;
    gboolean ok = (fgets (buf, (int) bufsz, fp) != NULL && buf[0] != '\0');
    pclose (fp);
    if (ok) {
        size_t len = strlen (buf);
        while (len > 0 && (buf[len-1] == '\n' || buf[len-1] == '\r' || buf[len-1] == ' '))
            buf[--len] = '\0';
    }
    return ok;
}

static gboolean try_hyprland (int *x, int *y) {
    if (!g_getenv ("HYPRLAND_INSTANCE_SIGNATURE")) { DBG("cursor: not Hyprland\n"); return FALSE; }
    char buf[64];
    if (!run_command ("hyprctl cursorpos 2>/dev/null", buf, sizeof buf)) { DBG("cursor: hyprctl failed\n"); return FALSE; }
    DBG("cursor: hyprctl output='%s'\n", buf);
    int xi, yi;
    if (sscanf (buf, "%d, %d", &xi, &yi) == 2) { *x=xi; *y=yi; return TRUE; }
    DBG("cursor: hyprctl parse failed\n");
    return FALSE;
}

static gboolean try_wlrctl (int *x, int *y) {
    char buf[64];
    if (!run_command ("wlrctl pointer position 2>/dev/null", buf, sizeof buf)) return FALSE;
    DBG("cursor: wlrctl output='%s'\n", buf);
    int xi, yi;
    if (sscanf (buf, "%d %d", &xi, &yi) == 2) { *x=xi; *y=yi; return TRUE; }
    return FALSE;
}

static gboolean try_ydotool (int *x, int *y) {
    char buf[128];
    if (!run_command ("ydotool getmouselocation 2>/dev/null", buf, sizeof buf)) return FALSE;
    DBG("cursor: ydotool output='%s'\n", buf);
    int xi, yi;
    if (sscanf (buf, "x:%d y:%d", &xi, &yi) == 2) { *x=xi; *y=yi; return TRUE; }
    return FALSE;
}

static gboolean try_xdotool (int *x, int *y) {
    char buf[128];
    if (!run_command ("xdotool getmouselocation 2>/dev/null", buf, sizeof buf)) return FALSE;
    DBG("cursor: xdotool output='%s'\n", buf);
    int xi, yi;
    if (sscanf (buf, "x:%d y:%d", &xi, &yi) == 2) { *x=xi; *y=yi; return TRUE; }
    return FALSE;
}

static gboolean try_gdk (int *x, int *y, GdkDisplay *display) {
    GdkSeat    *seat    = gdk_display_get_default_seat (display);
    GdkDevice  *pointer = gdk_seat_get_pointer (seat);
    double dx=0, dy=0;
    GdkSurface *surface = gdk_device_get_surface_at_position (pointer, &dx, &dy);
    DBG("cursor: GDK surface=%p pos=(%.0f,%.0f)\n", (void*)surface, dx, dy);
    if (surface) { *x=(int)dx; *y=(int)dy; return TRUE; }
    return FALSE;
}

static void
resolve_cursor_position (Config *cfg, GdkDisplay *display)
{
    if (cfg->cursor_x >= 0 && cfg->cursor_y >= 0) {
        DBG("cursor: using CLI pos (%d,%d)\n", cfg->cursor_x, cfg->cursor_y);
        return;
    }
    int x=0, y=0;
    if (try_hyprland(&x,&y)) { DBG("cursor: hyprland -> (%d,%d)\n",x,y); goto done; }
    if (try_wlrctl  (&x,&y)) { DBG("cursor: wlrctl  -> (%d,%d)\n",x,y); goto done; }
    if (try_ydotool (&x,&y)) { DBG("cursor: ydotool -> (%d,%d)\n",x,y); goto done; }
    if (try_xdotool (&x,&y)) { DBG("cursor: xdotool -> (%d,%d)\n",x,y); goto done; }
    if (try_gdk     (&x,&y,display)) { DBG("cursor: gdk -> (%d,%d)\n",x,y); goto done; }
    {
        GListModel  *monitors = gdk_display_get_monitors (display);
        GdkMonitor  *mon      = g_list_model_get_item (monitors, 0);
        GdkRectangle geom;
        gdk_monitor_get_geometry (mon, &geom);
        x = geom.x + geom.width  / 2;
        y = geom.y + geom.height / 2;
        g_object_unref (mon);
        DBG("cursor: FALLBACK monitor centre (%d,%d)\n", x, y);
    }
done:
    cfg->cursor_x = x;
    cfg->cursor_y = y;
}

/* ─── CLI parsing ────────────────────────────────────────────────────────── */

static void print_usage (const char *argv0) {
    fprintf (stderr,
        "Usage: %s [OPTIONS]\n\n"
        "  --x <int>          Cursor X (default: auto)\n"
        "  --y <int>          Cursor Y (default: auto)\n"
        "  --rings <1|2>      Number of rings (default: 1)\n"
        "  --radius <float>   Starting radius px (default: 80)\n"
        "  --duration <int>   Duration ms (default: 600)\n"
        "  --linewidth <f>    Stroke width px (default: 3.0)\n"
        "  --color <hex>      Colour #RRGGBB or #RRGGBBAA (default: #FF3333)\n"
        "  --help\n", argv0);
}

static gboolean
parse_hex_color (const char *hex, double *r, double *g, double *b, double *a)
{
    if (!hex || hex[0] != '#') return FALSE;
    hex++;
    unsigned int ri, gi, bi, ai = 255;
    int matched = 0;
    if      (strlen(hex)==8) matched = sscanf(hex,"%02x%02x%02x%02x",&ri,&gi,&bi,&ai);
    else if (strlen(hex)==6) matched = sscanf(hex,"%02x%02x%02x",    &ri,&gi,&bi);
    if (matched < 3) return FALSE;
    *r=ri/255.0; *g=gi/255.0; *b=bi/255.0; *a=ai/255.0;
    return TRUE;
}

static AppState g_state;

static gboolean
parse_args (int argc, char **argv, Config *cfg)
{
    cfg->cursor_x=DEFAULT_X; cfg->cursor_y=DEFAULT_Y;
    cfg->rings=DEFAULT_RINGS; cfg->radius=DEFAULT_RADIUS;
    cfg->duration_ms=DEFAULT_DURATION; cfg->line_width=DEFAULT_LINE_WIDTH;
    cfg->r=DEFAULT_COLOR_R; cfg->g=DEFAULT_COLOR_G;
    cfg->b=DEFAULT_COLOR_B; cfg->a=DEFAULT_COLOR_A;

    for (int i=1; i<argc; i++) {
        if (!strcmp(argv[i],"--help")||!strcmp(argv[i],"-h")) { print_usage(argv[0]); return FALSE; }
#define NX() if(i+1>=argc){fprintf(stderr,"Missing value for %s\n",argv[i]);return FALSE;}i++
        else if (!strcmp(argv[i],"--x"))         { NX(); cfg->cursor_x    = atoi(argv[i]); }
        else if (!strcmp(argv[i],"--y"))         { NX(); cfg->cursor_y    = atoi(argv[i]); }
        else if (!strcmp(argv[i],"--rings"))     { NX(); cfg->rings       = CLAMP(atoi(argv[i]),1,2); }
        else if (!strcmp(argv[i],"--radius"))    { NX(); cfg->radius      = atof(argv[i]); }
        else if (!strcmp(argv[i],"--duration"))  { NX(); cfg->duration_ms = atoi(argv[i]); }
        else if (!strcmp(argv[i],"--linewidth")) { NX(); cfg->line_width  = atof(argv[i]); }
        else if (!strcmp(argv[i],"--color"))     {
            NX();
            if (!parse_hex_color(argv[i],&cfg->r,&cfg->g,&cfg->b,&cfg->a)) {
                fprintf(stderr,"Bad color '%s'\n",argv[i]); return FALSE;
            }
        }
        else { fprintf(stderr,"Unknown: %s\n",argv[i]); print_usage(argv[0]); return FALSE; }
#undef NX
    }
    return TRUE;
}

/* ─── GTK activate + main ────────────────────────────────────────────────── */

static void
on_activate (GtkApplication *app, gpointer user_data)
{
    (void)user_data;
    DBG("on_activate: GTK activated\n");

    GdkDisplay *display = gdk_display_get_default ();
    DBG("on_activate: display=%p type=%s\n", (void*)display, G_OBJECT_TYPE_NAME(display));

    resolve_cursor_position (&g_state.cfg, display);
    DBG("on_activate: resolved cursor=(%d,%d)\n", g_state.cfg.cursor_x, g_state.cfg.cursor_y);

    g_state.app         = G_APPLICATION (app);
    g_state.window      = NULL;
    g_state.started     = FALSE;
    g_state.frame_count = 0;

    /* Hold the app so the main loop stays alive until we release it on destroy */
    g_application_hold (G_APPLICATION (app));
    DBG("on_activate: app hold acquired — main loop will stay alive\n");

    setup_window (&g_state, display);
}

int main (int argc, char **argv)
{
    DBG("main: cursor-ring debug build starting\n");

    if (!parse_args(argc, argv, &g_state.cfg)) return 1;

    DBG("main: rings=%d radius=%.0f dur=%dms lw=%.1f rgba=(%.2f,%.2f,%.2f,%.2f)\n",
        g_state.cfg.rings, g_state.cfg.radius, g_state.cfg.duration_ms, g_state.cfg.line_width,
        g_state.cfg.r, g_state.cfg.g, g_state.cfg.b, g_state.cfg.a);

    GtkApplication *app = gtk_application_new ("com.example.cursor-ring",
                                               G_APPLICATION_DEFAULT_FLAGS);
    g_signal_connect (app, "activate", G_CALLBACK(on_activate), NULL);

    int   fake_argc = 1;
    char *fake_argv[] = { argv[0], NULL };
    DBG("main: running GtkApplication\n");
    int status = g_application_run (G_APPLICATION(app), fake_argc, fake_argv);
    DBG("main: exited status=%d\n", status);

    g_object_unref (app);
    return status;
}