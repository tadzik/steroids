#include <SDL.h>
#include <SDL_image.h>
#include <SDL_ttf.h>
#include <stdlib.h>

typedef struct {
    SDL_Texture *tex;
    int w, h;
} Texture;

enum GamepadEventSources {
    ANALOG_LEFT_X,
    ANALOG_LEFT_Y,
    TRIGGER_LEFT,
    ANALOG_RIGHT_X,
    ANALOG_RIGHT_Y,
    TRIGGER_RIGHT,
    DPAD,
    BUTTONDOWN,
    BUTTONUP,
};

typedef struct {
    int id;
    int source;
    int value;
} GamepadEvent;

typedef struct {
    SDL_Window *window;
    SDL_Renderer *renderer;
    void (*keypressed_cb)(int);
    void (*gamepad_cb)(GamepadEvent*);
    void (*update_cb)(int);
    void (*draw_cb)(void);
    int running;
    int events_waiting;
    int frames_skipped;
} Game;

int timer_cb(int interval, void *arg)
{
    SDL_Event event;
    Game *g = (Game *)arg;
    if (g->events_waiting <= 3) {
        event.type = SDL_USEREVENT;
        SDL_PushEvent(&event);
        g->events_waiting++;
    } else {
        g->frames_skipped++;
    }
    return interval;
}

int
game_aabb_collision(SDL_Rect *a, SDL_Rect *b)
{
    return (abs(a->x - b->x) * 2 <= (a->w + b->w))
        && (abs(a->y - b->y) * 2 <= (a->h + b->h));
}

extern Game *
game_init(int width, int height)
{
    SDL_Init(SDL_INIT_EVERYTHING);
    TTF_Init();
    IMG_Init(IMG_INIT_PNG | IMG_INIT_JPG);
    SDL_JoystickEventState(SDL_ENABLE);

    int i;
    for (i = 0; i < SDL_NumJoysticks(); i++) {
        SDL_JoystickOpen(i);
    }

    Game *game = malloc(sizeof(Game));
    game->window = SDL_CreateWindow("Steroids", -1, -1, width, height, SDL_WINDOW_SHOWN);
    game->renderer = SDL_CreateRenderer(game->window, -1,
                                        SDL_RENDERER_ACCELERATED | SDL_RENDERER_PRESENTVSYNC);
    game->running = 1;
    game->keypressed_cb = NULL;
    game->gamepad_cb = NULL;
    game->update_cb = NULL;
    game->draw_cb = NULL;
    game->events_waiting = 0;
    game->frames_skipped = 0;

    SDL_AddTimer(16, (SDL_TimerCallback)timer_cb, game);

    return game;
}

extern void
game_quit(Game *game)
{
    game->running = 0;
}

extern void
game_set_keypressed_cb(Game *game, void (*keypressed_cb)(int))
{
    game->keypressed_cb = keypressed_cb;
}

extern void
game_set_gamepad_cb(Game *game, void (*gamepad_cb)(GamepadEvent*))
{
    game->gamepad_cb = gamepad_cb;
}

extern void
game_set_update_cb(Game *game, void (*update_cb)(int))
{
    game->update_cb = update_cb;
}

extern void
game_set_draw_cb(Game *game, void (*draw_cb)(void))
{
    game->draw_cb = draw_cb;
}

extern SDL_Renderer *
game_get_renderer(Game *game)
{
    return game->renderer;
}

extern Texture *
game_load_texture(Game *game, const char *path)
{
    //TODO Handle errors
    Texture *ret = malloc(sizeof(Texture));
    SDL_Surface *img = IMG_Load(path);
    if (!img) {
        printf("%s\n", IMG_GetError());
    }
    ret->tex = SDL_CreateTextureFromSurface(game->renderer, img);
    ret->w = img->w;
    ret->h = img->h;
    SDL_FreeSurface(img);
    return ret;
}

extern void
game_free_texture(Texture *t)
{
    SDL_DestroyTexture(t->tex);
    free(t);
}

extern void
game_renderer_clear(Game *game)
{
    SDL_RenderClear(game->renderer);
}

extern void
game_draw_texture(Game *game, Texture *tex, int x, int y)
{
    SDL_Rect dest;
    dest.w = tex->w;
    dest.h = tex->h;
    dest.x = x;
    dest.y = y;
    SDL_RenderCopy(game->renderer, tex->tex, NULL, &dest);
}

extern void
game_draw_spritesheet_frame(Game *game, Texture *sheet,
                            int framew, int frameh, int frameno,
                            int x, int y)
{
    SDL_Rect src, dest;

    int off = frameno * framew;
    src.x = off % sheet->w;
    src.y = (off / sheet->w) * frameh;
    dest.x = x;
    dest.y = y;
    src.w = dest.w = framew;
    src.h = dest.h = frameh;
    SDL_RenderCopy(game->renderer, sheet->tex, &src, &dest);
}

extern void game_renderer_present(Game *game) {
    SDL_RenderPresent(game->renderer);
}

extern int
game_is_pressed(int idx)
{
    const Uint8 *state = SDL_GetKeyboardState(NULL);

    return !!state[idx];
}

extern int
game_is_pressed_name(const char *name)
{
    SDL_Keycode key = SDL_GetKeyFromName(name);
    int idx = SDL_GetScancodeFromKey(key);
    return game_is_pressed(idx);
}

extern int
game_is_running(Game *game)
{
    return game->running;
}

extern void
game_loop(Game *game)
{
    SDL_Event event;
    GamepadEvent gev;
    Uint32 lasttime, currenttime;
    lasttime = 0;
    while (game->running) {
        SDL_WaitEvent(&event);
        switch (event.type) {
        case SDL_USEREVENT: // timer
            game->events_waiting--;
            currenttime = SDL_GetTicks();
            game->update_cb(currenttime - lasttime);
            lasttime = currenttime;
            game->draw_cb();
            break;
        case SDL_KEYDOWN:
            if (!event.key.repeat) {
                if (game->keypressed_cb) game->keypressed_cb(event.key.keysym.sym);
            }
            break;
        //case SDL_KEYUP:
        case SDL_JOYAXISMOTION:
            gev.id = event.jaxis.which;
            gev.source = event.jaxis.axis;
            gev.value = event.jaxis.value;
            game->gamepad_cb(&gev);
            break;
        case SDL_JOYBUTTONDOWN:
            gev.id = event.jbutton.which;
            gev.source = BUTTONDOWN;
            gev.value = event.jbutton.button;
            game->gamepad_cb(&gev);
            break;
        case SDL_JOYBUTTONUP:
            gev.id = event.jbutton.which;
            gev.source = BUTTONUP;
            gev.value = event.jbutton.button;
            game->gamepad_cb(&gev);
            break;
        case SDL_JOYHATMOTION:
            gev.id = event.jhat.which;
            gev.source = DPAD;
            gev.value = event.jhat.value;
            game->gamepad_cb(&gev);
            break;
        case SDL_QUIT:
            game->running = 0;
            break;
        }
    }
}

extern void
game_free(Game *game)
{
    printf("%d frames skipped\n", game->frames_skipped);
    SDL_DestroyRenderer(game->renderer);
    SDL_DestroyWindow(game->window);
    SDL_Quit();
    free(game);
}

extern TTF_Font *
game_open_font(const char *path, int size)
{
    TTF_Font *ret = TTF_OpenFont(path, size);
    if (!ret) {
        printf("Error loading font: %s\n", TTF_GetError());
    }
    return ret;
}

extern Texture *
game_render_text(Game *game, TTF_Font *font, const char *text, int r, int g, int b, int a)
{
    SDL_Color color = { r, g, b, a };
    SDL_Surface *surf = TTF_RenderText_Solid(font, text, color);
    if (!surf) {
        printf("Error rendering text: %s\n", TTF_GetError());
        return NULL;
    }
    SDL_Texture *tex = SDL_CreateTextureFromSurface(game->renderer, surf);
    Texture *ret = malloc(sizeof(Texture));
    ret->tex = tex;
    ret->w = surf->w;
    ret->h = surf->h;
    return ret;
}
