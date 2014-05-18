class Steroids::State {
    use Steroids::SDL;
    use Steroids::Colour;
    use Steroids::Entity;
    use Steroids::Animation;
    has Mu $!game;
    # the actual Steroids::Game object
    has $.parent handles<is_pressed quit load_bitmap load_font load_spritesheet
                         assets width height gamepads change_state reset_state> is rw;
    has @.entities;
    has @!animations;
    has $.paused is rw;

    method create { ... }
    method update(int) { ... }
    method keypressed($k) { }
    method gamepad($ev) { }

    multi method add_sprite(Str $asset, Int $x, Int $y) {
        unless %.assets{$asset}:exists {
            die "No such asset loaded: $asset"
        }
        my $d = Steroids::Entity.new(:$x, :$y, :img(%.assets{$asset}));
        @!entities.push: $d;
        return $d;
    }

    multi method add_sprite(Texture $sprite, Int $x, Int $y) {
        my $d = Steroids::Entity.new(:$x, :$y, :img($sprite));
        @!entities.push: $d;
        return $d;
    }

    method remove_sprite(Steroids::Entity $d) {
        @!entities.=grep(* !=== $d);
    }

    method add_animation(Steroids::Entity $entity, $frames is copy, $step, $loop) {
        unless $frames {
            $frames = 0..^$entity.img.framecnt;
        }
        my $a = Steroids::Animation.new(:$entity, :$frames, :$step, :$loop);
        @!animations.push: $a;
        return $a;
    }

    method remove_animation(Steroids::Animation $a) {
        @!animations.=grep(* !=== $a);
    }

    method add_text(Str $text, Str $font, Steroids::Colour $c, Int $x, Int $y) {
        unless self.parent.fonts{$font}:exists {
            die "Font $font not loaded"
        }
        my Mu $f := self.parent.fonts{$font};
        my $tex = game_render_text($!game, $f, $text, $c.red, $c.green, $c.blue, $c.alpha);
        return self.add_sprite($tex, $x, $y);
    }

    method animations(int32 $dt) {
        return if $!paused;
        my @active;
        for @!animations {
            if $_.advance($dt) {
                @active.push: $_
            }
        }
        @!animations = @active
    }

    method events {
        return if $!paused;
        for @!entities -> $ent {
            next unless $ent.events;
            for $ent.events -> $ev {
                if $ev[0].($ent) {
                    $ev[1].($ent)
                }
            }
        }
    }

    method physics(int32 $dt) {
        return if $!paused;
        for @!entities {
            $_.x += $_.velocity[0] if $_.velocity[0];
            $_.y += $_.velocity[1] if $_.velocity[1];
        }
    }

    method draw {
        game_renderer_clear($!game);
        for @!entities {
            $_.draw($!game)
        }
        game_renderer_present($!game);
    }
}

