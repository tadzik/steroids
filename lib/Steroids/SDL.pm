use NativeCall;
constant PATH = './sdlwrapper';

class Texture is repr('CStruct') {
    has OpaquePointer $.tex;
    has int32 $.w;
    has int32 $.h;

    method draw($game, Int $x, Int $y, Int $frame) {
        game_draw_texture($game, self, $x, $y)
    }

    method free {
        game_free_texture(self)
    }
}

class Steroids::Gamepad::Event is repr('CStruct') {
    has int32 $.id;
    has int32 $.source;
    has int32 $.value;

    method type {
        return <analog_left_x analog_left_y trigger_left
                analog_right_x analog_right_y trigger_right
                dpad button_down button_up>[$!source]
    }

    method button {
        my @button_names = <A B X Y LB RB BACK START XBOX LA RA>;
        return @button_names[$!value];
    }
}

class Rectangle is repr('CStruct') {
    has int32 $.x;
    has int32 $.y;
    has int32 $.w;
    has int32 $.h;
}

sub game_aabb_collision(Rectangle, Rectangle) returns Int          is native(PATH) is export { * }

sub game_init(int32, int32) returns OpaquePointer                  is native(PATH) is export { * } 
sub game_set_keypressed_cb(OpaquePointer, &cb(int32))              is native(PATH) is export { * }
sub game_set_gamepad_cb(OpaquePointer, &cb(Steroids::Gamepad::Event)) is native(PATH) is export { * }
sub game_set_update_cb(OpaquePointer, &cb(int32))                  is native(PATH) is export { * }
sub game_set_draw_cb(OpaquePointer, &cb())                         is native(PATH) is export { * }
sub game_is_pressed(int32) returns int32                           is native(PATH) is export { * }
sub game_is_pressed_name(Str) returns int32                        is native(PATH) is export { * }
sub game_is_running(OpaquePointer) returns int32                   is native(PATH) is export { * }
sub game_loop(OpaquePointer)                                       is native(PATH) is export { * }
sub game_quit(OpaquePointer)                                       is native(PATH) is export { * }
sub game_free(OpaquePointer)                                       is native(PATH) is export { * }
sub game_load_texture(OpaquePointer, Str) returns Texture          is native(PATH) is export { * }
sub game_free_texture(Texture)                                     is native(PATH) is export { * }
sub game_renderer_clear(OpaquePointer)                             is native(PATH) is export { * }
sub game_draw_texture(OpaquePointer, Texture, int32, int32)        is native(PATH) is export { * }
sub game_draw_spritesheet_frame(OpaquePointer, Texture,
                                int32, int32, int32, int32, int32) is native(PATH) is export { * }
                                # fw    fh     fn      x      y
sub game_renderer_present(OpaquePointer)                           is native(PATH) is export { * }
sub game_render_text(OpaquePointer, OpaquePointer, Str, int32, int32, int32, int32)
                                                   returns Texture is native(PATH) is export { * }
sub game_open_font(Str, int32) returns OpaquePointer               is native(PATH) is export { * }

sub SDL_GetKeyName(int32) returns Str                         is native(PATH) is export { * }
sub SDL_NumJoysticks() returns int32                          is native(PATH) is export { * }

