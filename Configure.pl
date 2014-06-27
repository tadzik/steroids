use v6;

my $name = 'sdlwrapper';
my ($c_line, $l_line);
if $*VM.name eq 'parrot' {
    my $cfg = $*VM.config;
    my $o  = $cfg<o>;
    my $so = $cfg<load_ext>;
    $c_line = "-c $cfg<cc_shared> $cfg<cc_o_out>$name$o $cfg<ccflags> $name.c";
    $l_line = "$cfg<ld_load_flags> $cfg<ldflags> " ~
        "$cfg<libs> $cfg<ld_out>$name$so $name$o";
}
elsif $*VM.name eq 'moar' {
    my $cfg = $*VM.config;
    my $o  = $cfg<obj>;
    my $so = $cfg<dll>.subst('lib%s', '');
    $c_line = "-c $cfg<ccshared> $cfg<ccout>$name$o $cfg<cflags> $name.c";
    $l_line = "$cfg<ldshared> $cfg<ldflags> " ~
        "$cfg<ldlibs> $cfg<ldout>$name$so $name$o";
}
elsif $*VM.name eq 'jvm' {
    #say "$*VM<config><nativecall.ccdlflags>";
    my $cfg = $*VM.config;
    $c_line = "-c $cfg<nativecall.ccdlflags> -o$name$cfg<nativecall.o> $cfg<nativecall.ccflags> $name.c";
    $l_line = "$cfg<nativecall.libs> $cfg<nativecall.lddlflags> $cfg<nativecall.ldflags> $cfg<nativecall.ldout>$name.$cfg<nativecall.so> $name$cfg<nativecall.o>";
}
else {
    die "Unknown VM; don't know how to compile libraires";
}

given open('Makefile.sdlwrapper', :w) {
    .say:
q[LIBS=$(shell sdl2-config --libs) -lSDL2_image -lSDL2_ttf
CFLAGS=$(shell sdl2-config --cflags)] ~ qq[

all: sdlwrapper.so

sdlwrapper.so: sdlwrapper.c
	cc \$(CFLAGS) $c_line
	cc $l_line \$(LIBS) 

clean:
	rm -f *.so *.o];
    .close;
}
