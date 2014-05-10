class Steroids::Animation {
    use Steroids::Entity;
    has Steroids::Entity $.entity;
    has @.frames;
    has $.step;
    has $.loop;
    has $.paused is rw;
    has $!current = 0;
    has $!elapsed = 0;
    has $.finished;

    method advance(int32 $dt) {
        return True if $!paused;
        $!elapsed += $dt;
        while $!elapsed > $!step {
            $!current++;
            if $!current == @!frames.elems {
                if $!loop {
                    $!current = 0
                } else {
                    $!finished = True;
                    return False # don't animate again
                }
            }
            $!elapsed -= $!step;
        }
        $!entity.frame = @!frames[$!current];
        return True # keep animating
    }
}
