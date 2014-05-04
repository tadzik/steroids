use v6;

my $name = 'sdlwrapper';
my ($c_line, $l_line);
if $*VM<name> eq 'parrot' {
    my $o  = $*VM<config><o>;
    my $so = $*VM<config><load_ext>;
    $c_line = "-c $*VM<config><cc_shared> $*VM<config><cc_o_out>$name$o $*VM<config><ccflags> $name.c";
    $l_line = "$*VM<config><ld_load_flags> $*VM<config><ldflags> " ~
        "$*VM<config><libs> $*VM<config><ld_out>$name$so $name$o";
}
elsif $*VM<name> eq 'moar' {
    my $o  = $*VM<config><obj>;
    my $so = $*VM<config><dll>.subst('%s', '');
    $c_line = "-c $*VM<config><ccshared> $*VM<config><ccout>$name$o $*VM<config><cflags> $name.c";
    $l_line = "$*VM<config><ldshared> $*VM<config><ldflags> " ~
        "$*VM<config><ldlibs> $*VM<config><ldout>$name$so $name$o";
}
elsif $*VM<name> eq 'jvm' {
    #say "$*VM<config><nativecall.ccdlflags>";
    my $cfg = $*VM<config>;
    $c_line = "-c $cfg<nativecall.ccdlflags> -o$name$cfg<nativecall.o> $cfg<nativecall.ccflags> $name.c";
    $l_line = "$cfg<nativecall.libs> $cfg<nativecall.lddlflags> $cfg<nativecall.ldflags> $cfg<nativecall.ldout>$name.$cfg<nativecall.so> $name$cfg<nativecall.o>";
}
else {
    die "Unknown VM; don't know how to compile libraires";
}

given open('Makefile', :w) {
    .say:
q[LIBS=$(shell sdl2-config --libs) -lSDL2_image
CFLAGS=$(shell sdl2-config --cflags)] ~ qq[

all: sdlwrapper.so

sdlwrapper.so: sdlwrapper.c
	cc \$(CFLAGS) $c_line
	cc $l_line \$(LIBS) 

clean:
	rm -f *.so *.o];
    .close;
}
