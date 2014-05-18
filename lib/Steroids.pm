module Steroids;

class Game {
    use Steroids::SDL;
    use Steroids::State;
    use Steroids::Gamepad;
    use Steroids::Spritesheet;
    has $.width;
    has $.height;
    has Mu $!game;
    has %.assets;
    has %.fonts;
    has %.states;
    has %.state-factories;
    has $!current-state;
    has @.gamepads = Steroids::Gamepad.new;
    
    submethod BUILD(:$!width = 1024, :$!height = 768) {
        $!game := game_init($!width, $!height);
        for ^SDL_NumJoysticks() {
            @!gamepads.push: Steroids::Gamepad.new;
        }
    }

    multi method is_pressed(int32 $key) {
        game_is_pressed($key);
    }

    multi method is_pressed(Str $key) {
        game_is_pressed_name($key);
    }

    method add_state(Str $name, &state) {
        %!state-factories{$name} = &state;
    }

    method change_state(Str $name) {
        $!current-state = $name;
        unless %!states{$name} {
            self.reset_state($name);
        }
    }

    method reset_state(Str $name) {
        my $state = %!state-factories{$name}.();
        $state.parent = self;
        nqp::bindattr(nqp::decont($state), Steroids::State, '$!game', $!game);
        $state.create;
        %!states{$name} = $state;
    }

    method start {
        unless $!current-state {
            die "Cannot start a game with no state set"
        }
        sub key_cb(int32 $k) {
            my $cur = %!states{$!current-state};
            my $str = SDL_GetKeyName($k);
            my $key = nqp::p6box_i($k) but role { method Str { $str } };
            $cur.keypressed($key);
            CATCH {
                .say
            }
        }
        sub gamepad_cb(Steroids::Gamepad::Event $ev) {
            my $cur = %!states{$!current-state};
            self.gamepads[$ev.id].update($ev);
            $cur.gamepad($ev);
            CATCH {
                .say
            }
        }
        sub update_cb(int32 $dt) {
            state $cnt = 0;
            my $cur = %!states{$!current-state};
            my $t0 = nqp::time_n();
            $cur.physics($dt);
            my $t1 = nqp::time_n();
            $cur.events();
            my $t2 = nqp::time_n();
            $cur.animations($dt);
            my $t3 = nqp::time_n();
            $cur.update($dt);
            my $t4 = nqp::time_n();
            CATCH {
                .say
            }
            if $cnt++ %% 30 {
                if $t4 - $t0 > 0.016 {
                    say    "====TOO SLOW!!====";
                    printf "Frame took: %.4f\n", $t4 - $t0;
                    printf "Physics:    %.4f\n", $t1 - $t0;
                    printf "Events:     %.4f\n", $t2 - $t1;
                    printf "Animations: %.4f\n", $t3 - $t2;
                    printf "update():   %.4f\n", $t4 - $t3;
                }
            }
        }
        sub draw_cb {
            state $cnt = 0;
            my $cur = %!states{$!current-state};
            my $t0 = nqp::time_n();
            $cur.draw();
            my $t1 = nqp::time_n();
            if $cnt++ %% 30 {
                if $t1 - $t0 > 0.016 {
                    say    "====TOO SLOW!!====";
                    printf "Rendering:  %.4f\n", $t1 - $t0;
                }
            }
            CATCH {
                .say
            }
        }
        game_set_keypressed_cb($!game, &key_cb);
        game_set_update_cb($!game, &update_cb);
        game_set_gamepad_cb($!game, &gamepad_cb);
        game_set_draw_cb($!game, &draw_cb);
        game_loop($!game);
        game_free($!game);
    }

    method quit { game_quit($!game) }

    method load_font(Str $name, Str $path, Int $size) {
        my Mu $font = game_open_font($path, $size);
        %!fonts{$name} := $font;
    }

    method load_bitmap(Str $name, Str $path) {
        %!assets{$name}.?free;
        %!assets{$name} = game_load_texture($!game, $path);
    }

    method load_spritesheet(Str $name, Str $path,
                            Int $w, Int $h, Int $framecnt) {
        %!assets{$name}.?free;
        my $tex = game_load_texture($!game, $path);
        %!assets{$name} = Steroids::Spritesheet.new(:$tex, :$w, :$h, :$framecnt);
    }
}
