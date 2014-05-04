class Steroids::Gamepad {
    has $.analog_left_x = 0;
    has $.analog_left_y = 0;
    has $.analog_right_x = 0;
    has $.analog_right_y = 0;
    has $.trigger_left = 0;
    has $.trigger_right = 0;
    has $.dpad = 0;
    has @.buttons;

    my @button_names = <A B X Y LB RB BACK START XBOX LA RA>;
    my %button_mapping = @button_names.kv.hash.invert;

    method dpad_position($which) {
        my %values = Center => 0,
                     Up => 1,
                     Right => 2,
                     Down => 4,
                     Left => 8;
        return so $!dpad +& %values{$which};
    }

    method is_pressed(Str $name) {
        return so @!buttons[%button_mapping{$name}]
    }

    method analog_percentage($which) {
        my $perc = $which / 32767;
        if $perc.abs < 0.1 {
            return 0
        }
        return $perc;
    }

    method update($ev) {
        my @mappings;
        @mappings[0] := $!analog_left_x;
        @mappings[1] := $!analog_left_y;
        @mappings[2] := $!trigger_left;
        @mappings[3] := $!analog_right_x;
        @mappings[4] := $!analog_right_y;
        @mappings[5] := $!trigger_right;
        @mappings[6] := $!dpad;
        if $ev.source < 7 {
            @mappings[$ev.source] = $ev.value;
        } elsif $ev.source == 7 {
            @!buttons[$ev.value] = True;
        } else {
            @!buttons[$ev.value] = False;
        }
    }
}
