Space Invaders
==============

Stop the alien hordes and protect the earth being the last hope of the human race!

This game features ANIMATIONS, EXPLOSIONS, GAMEPADS, MENUS and more!

This time, in addition to SDL2 and SDL2_image you need SDL2_ttf too.
Rakudo/MoarVM is basically a necessity at this point. Parrot can run this, but awfully slow
and JVM has a bug that makes it impossible to run the game.

Assets, as usual, are happily taken from opengameart.org; spaceship created by Keleborn,
alien ship by Cuzco, laser beam by Rawdanitsu. Space background if taken from wikimedia commons.

Soundtrack for Space Invaders is, obviously, Iron Maiden's “Invaders”. Listen to it
here: http://www.youtube.com/watch?v=63gdZAsl62E.

To build, first run 'perl6 Configure.pl' and then 'make' and 'make -f Makefile.sdlwrapper'.
If all goes well you should be able to run the game by running './SpaceInvaders'.

In game you can use the arrow keys (left and right) to move and space (or up arrow) to shoot,
or an XBOX controller (steer with left analogue stick or a dpad, shoot with A). You can also
pause a game with either Escape or gamepad's Start button, if fighting off the aliens becomes
too intense.

You can only shoot a few bullet at once; this is a feature, the guns obviously need to cool down.
Also, a lot of shots fired kill not only aliens, but performance too.

Have a lot of fun!
