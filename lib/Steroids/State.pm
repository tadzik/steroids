class Steroids::State {
    use Steroids::SDL;
    use Steroids::Entity;
    use Steroids::Animation;
    has Mu $!game;
    # the actual Steroids::Game object
    has $.parent handles<is_pressed quit load_bitmap load_spritesheet
                         assets width height gamepads> is rw;
    has @.entities;
    has @!animations;

    method create { ... }
    method update(int) { ... }
    method keypressed($k) { }
    method gamepad($ev) { }

    method activate {
        sub key_cb(int32 $k) {
            my $str = SDL_GetKeyName($k);
            my $key = nqp::p6box_i($k) but role { method Str { $str } };
            self.keypressed($key);
            CATCH {
                .say
            }
        }
        sub gamepad_cb(Steroids::Gamepad::Event $ev) {
            self.gamepads[$ev.id].update($ev);
            self.gamepad($ev);
            CATCH {
                .say
            }
        }
        sub update_cb(int32 $dt) {
            self.physics($dt);
            self.events();
            self.animations($dt);
            self.update($dt);
            CATCH {
                .say
            }
        }
        sub draw_cb {
            self.draw();
            CATCH {
                .say
            }
        }
        game_set_keypressed_cb($!game, &key_cb);
        game_set_update_cb($!game, &update_cb);
        game_set_gamepad_cb($!game, &gamepad_cb);
        game_set_draw_cb($!game, &draw_cb);
    }

    method add_sprite(Str $asset, Int $x, Int $y) {
        unless %.assets{$asset}:exists {
            die "No such asset loaded: $asset"
        }
        my $d = Steroids::Entity.new(:$x, :$y, :img(%.assets{$asset}));
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

    method animations(int32 $dt) {
        my @active;
        for @!animations {
            if $_.advance($dt) {
                @active.push: $_
            }
        }
        @!animations = @active
    }

    method events {
        for @!entities -> $ent {
            for $ent.events -> $ev {
                if $ev[0].($ent) {
                    $ev[1].($ent)
                }
            }
        }
    }

    method physics(int32 $dt) {
        for @!entities {
            $_.x += $_.velocity[0];
            $_.y += $_.velocity[1];
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

