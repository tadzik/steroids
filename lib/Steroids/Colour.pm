class Steroids::Colour {
    has int32 $.red;
    has int32 $.green;
    has int32 $.blue;
    has int32 $.alpha;

    method white {
        return self.new(red => 255, green => 255, blue => 255, alpha => 255)
    }
}
