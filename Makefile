.PHONY: all build test install clean distclean purge

PERL6  = perl6-m
DESTDIR= 
PREFIX = ~/.rakudobrew/moar-HEAD/install/languages/perl6/site
BLIB   = blib
P6LIB  = $(PWD)/$(BLIB)/lib:$(PWD)/lib:$(PERL6LIB)
CP     = cp -p
MKDIR  = mkdir -p


BLIB_COMPILED = $(BLIB)/lib/Steroids.moarvm $(BLIB)/lib/Steroids/SDL.moarvm $(BLIB)/lib/Steroids/Colour.moarvm $(BLIB)/lib/Steroids/Spritesheet.moarvm $(BLIB)/lib/Steroids/Entity.moarvm $(BLIB)/lib/Steroids/State.moarvm $(BLIB)/lib/Steroids/Animation.moarvm $(BLIB)/lib/Steroids/Gamepad.moarvm

all build: $(BLIB_COMPILED)

$(BLIB)/lib/Steroids.moarvm : lib/Steroids.pm $(BLIB)/lib/Steroids/SDL.moarvm $(BLIB)/lib/Steroids/State.moarvm $(BLIB)/lib/Steroids/Gamepad.moarvm $(BLIB)/lib/Steroids/Spritesheet.moarvm
	$(MKDIR) $(BLIB)/lib/
	$(CP) lib/Steroids.pm $(BLIB)/lib/Steroids.pm
	PERL6LIB=$(P6LIB) $(PERL6) --target=mbc --output=$(BLIB)/lib/Steroids.moarvm lib/Steroids.pm

$(BLIB)/lib/Steroids/SDL.moarvm : lib/Steroids/SDL.pm
	$(MKDIR) $(BLIB)/lib/Steroids/
	$(CP) lib/Steroids/SDL.pm $(BLIB)/lib/Steroids/SDL.pm
	PERL6LIB=$(P6LIB) $(PERL6) --target=mbc --output=$(BLIB)/lib/Steroids/SDL.moarvm lib/Steroids/SDL.pm

$(BLIB)/lib/Steroids/Colour.moarvm : lib/Steroids/Colour.pm
	$(MKDIR) $(BLIB)/lib/Steroids/
	$(CP) lib/Steroids/Colour.pm $(BLIB)/lib/Steroids/Colour.pm
	PERL6LIB=$(P6LIB) $(PERL6) --target=mbc --output=$(BLIB)/lib/Steroids/Colour.moarvm lib/Steroids/Colour.pm

$(BLIB)/lib/Steroids/Spritesheet.moarvm : lib/Steroids/Spritesheet.pm $(BLIB)/lib/Steroids/SDL.moarvm
	$(MKDIR) $(BLIB)/lib/Steroids/
	$(CP) lib/Steroids/Spritesheet.pm $(BLIB)/lib/Steroids/Spritesheet.pm
	PERL6LIB=$(P6LIB) $(PERL6) --target=mbc --output=$(BLIB)/lib/Steroids/Spritesheet.moarvm lib/Steroids/Spritesheet.pm

$(BLIB)/lib/Steroids/Entity.moarvm : lib/Steroids/Entity.pm $(BLIB)/lib/Steroids/SDL.moarvm
	$(MKDIR) $(BLIB)/lib/Steroids/
	$(CP) lib/Steroids/Entity.pm $(BLIB)/lib/Steroids/Entity.pm
	PERL6LIB=$(P6LIB) $(PERL6) --target=mbc --output=$(BLIB)/lib/Steroids/Entity.moarvm lib/Steroids/Entity.pm

$(BLIB)/lib/Steroids/State.moarvm : lib/Steroids/State.pm $(BLIB)/lib/Steroids/SDL.moarvm $(BLIB)/lib/Steroids/Colour.moarvm $(BLIB)/lib/Steroids/Entity.moarvm $(BLIB)/lib/Steroids/Animation.moarvm
	$(MKDIR) $(BLIB)/lib/Steroids/
	$(CP) lib/Steroids/State.pm $(BLIB)/lib/Steroids/State.pm
	PERL6LIB=$(P6LIB) $(PERL6) --target=mbc --output=$(BLIB)/lib/Steroids/State.moarvm lib/Steroids/State.pm

$(BLIB)/lib/Steroids/Animation.moarvm : lib/Steroids/Animation.pm $(BLIB)/lib/Steroids/Entity.moarvm
	$(MKDIR) $(BLIB)/lib/Steroids/
	$(CP) lib/Steroids/Animation.pm $(BLIB)/lib/Steroids/Animation.pm
	PERL6LIB=$(P6LIB) $(PERL6) --target=mbc --output=$(BLIB)/lib/Steroids/Animation.moarvm lib/Steroids/Animation.pm

$(BLIB)/lib/Steroids/Gamepad.moarvm : lib/Steroids/Gamepad.pm
	$(MKDIR) $(BLIB)/lib/Steroids/
	$(CP) lib/Steroids/Gamepad.pm $(BLIB)/lib/Steroids/Gamepad.pm
	PERL6LIB=$(P6LIB) $(PERL6) --target=mbc --output=$(BLIB)/lib/Steroids/Gamepad.moarvm lib/Steroids/Gamepad.pm


test: build
	env PERL6LIB=$(P6LIB) prove -e '$(PERL6)' -r t/

loudtest: build
	env PERL6LIB=$(P6LIB) prove -ve '$(PERL6)' -r t/

timetest: build
	env PERL6LIB=$(P6LIB) PERL6_TEST_TIMES=1 prove -ve '$(PERL6)' -r t/

install: $(BLIB_COMPILED)
	$(MKDIR) $(DESTDIR)$(PREFIX)/lib/
	$(CP) $(BLIB)/lib/Steroids.pm $(DESTDIR)$(PREFIX)/lib/Steroids.pm
	$(CP) $(BLIB)/lib/Steroids.moarvm $(DESTDIR)$(PREFIX)/lib/Steroids.moarvm
	$(MKDIR) $(DESTDIR)$(PREFIX)/lib/Steroids/
	$(CP) $(BLIB)/lib/Steroids/SDL.pm $(DESTDIR)$(PREFIX)/lib/Steroids/SDL.pm
	$(CP) $(BLIB)/lib/Steroids/SDL.moarvm $(DESTDIR)$(PREFIX)/lib/Steroids/SDL.moarvm
	$(MKDIR) $(DESTDIR)$(PREFIX)/lib/Steroids/
	$(CP) $(BLIB)/lib/Steroids/Colour.pm $(DESTDIR)$(PREFIX)/lib/Steroids/Colour.pm
	$(CP) $(BLIB)/lib/Steroids/Colour.moarvm $(DESTDIR)$(PREFIX)/lib/Steroids/Colour.moarvm
	$(MKDIR) $(DESTDIR)$(PREFIX)/lib/Steroids/
	$(CP) $(BLIB)/lib/Steroids/Spritesheet.pm $(DESTDIR)$(PREFIX)/lib/Steroids/Spritesheet.pm
	$(CP) $(BLIB)/lib/Steroids/Spritesheet.moarvm $(DESTDIR)$(PREFIX)/lib/Steroids/Spritesheet.moarvm
	$(MKDIR) $(DESTDIR)$(PREFIX)/lib/Steroids/
	$(CP) $(BLIB)/lib/Steroids/Entity.pm $(DESTDIR)$(PREFIX)/lib/Steroids/Entity.pm
	$(CP) $(BLIB)/lib/Steroids/Entity.moarvm $(DESTDIR)$(PREFIX)/lib/Steroids/Entity.moarvm
	$(MKDIR) $(DESTDIR)$(PREFIX)/lib/Steroids/
	$(CP) $(BLIB)/lib/Steroids/State.pm $(DESTDIR)$(PREFIX)/lib/Steroids/State.pm
	$(CP) $(BLIB)/lib/Steroids/State.moarvm $(DESTDIR)$(PREFIX)/lib/Steroids/State.moarvm
	$(MKDIR) $(DESTDIR)$(PREFIX)/lib/Steroids/
	$(CP) $(BLIB)/lib/Steroids/Animation.pm $(DESTDIR)$(PREFIX)/lib/Steroids/Animation.pm
	$(CP) $(BLIB)/lib/Steroids/Animation.moarvm $(DESTDIR)$(PREFIX)/lib/Steroids/Animation.moarvm
	$(MKDIR) $(DESTDIR)$(PREFIX)/lib/Steroids/
	$(CP) $(BLIB)/lib/Steroids/Gamepad.pm $(DESTDIR)$(PREFIX)/lib/Steroids/Gamepad.pm
	$(CP) $(BLIB)/lib/Steroids/Gamepad.moarvm $(DESTDIR)$(PREFIX)/lib/Steroids/Gamepad.moarvm


clean:
	rm -fr $(BLIB)

distclean purge: clean
	rm -r Makefile
