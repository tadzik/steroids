class Steroids::Entity {
    use Steroids::SDL;
    has Int $.x is rw;
    has Int $.y is rw;
    has $.velocity is rw = [0, 0];
    has $.img handles <w h>;
    has @.events;
    has $.payload; # whatever the user wants to put here

    method draw($game) {
        $!img.draw($game, $!x, $!y)
    }

    method when (&condition, &action) {
        @!events.push: [&condition, &action];
    }

    # XXX custom hitboxes
    method collides_with(Steroids::Entity $other) {
        if ($other.x <= $!x <= $other.x + $other.w
            or $other.x < $!x + self.w < $other.x + $other.w)
        and ($other.y <= $!y <= $other.y + $other.h
            or $other.y <= $!y + self.h <= $other.y + $other.h) {
            return True
        }
        return False
    }
}
