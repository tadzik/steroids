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
        abs($!x - $other.x) * 2 <= ($.w + $other.w) and
        abs($!y - $other.y) * 2 <= ($.h + $other.h)
    }
}
