class Steroids::Spritesheet {
    use Steroids::SDL;
    has Texture $.tex;
    has int32 $.w;
    has int32 $.h;
    has int32 $.framecnt;
    has $.frame is rw = 0;

    method draw($game, $x, $y) {
        game_draw_spritesheet_frame($game, $!tex, $!w, $!h, $!frame, $x, $y)
    }
}
