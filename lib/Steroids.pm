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
    has %!states;
    has $!current-state;
    has @.gamepads = Steroids::Gamepad.new;
    
    submethod BUILD(:$!width, :$!height) {
        $!width //= 1024;
        $!height //= 768;
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

    method add_state(Str $name, Steroids::State $state) {
        $state.parent = self;
        nqp::bindattr($state, Steroids::State, '$!game', $!game);
        %!states{$name} = $state;
        $state.create;
        return self
    }

    method change_state(Str $name) {
        $!current-state = $name;
        %!states{$!current-state}.activate;
        return self
    }

    method start {
        unless $!current-state {
            die "Cannot start a game with no state set"
        }
        game_loop($!game);
        game_free($!game);
    }

    method quit { game_quit($!game) }

    method load_bitmap(Str $name, Str $path) {
        %!assets{$name} = game_load_texture($!game, $path);
    }

    method load_spritesheet(Str $name, Str $path,
                            Int $w, Int $h, Int $framecnt) {
        my $tex = game_load_texture($!game, $path);
        %!assets{$name} = Steroids::Spritesheet.new(:$tex, :$w, :$h, :$framecnt);
    }
}
