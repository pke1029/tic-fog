# tic-fog
TIC-80 layer management library.

![](demo.gif)

Check out the demo [here](https://tic.computer/play?cart=913).

Ever wanted to draw anti-circle? Or somekind of layering system in TIC? If so, this is the library for you! Simply copy the fog table and you are set to go!

FOG uses the lower half of the memory of MAP on the vram (`0xbfc0` up to but not including `0xff80`) as a second screen/canvas. You are free to draw on the canvas and whenever one wants to display the content of the canvas, one simply call the function `fog.show()` with the optional parameter of a `colorkey` (the color you'd like to be invinsible). It's as simple as that.


WARNING: It will temporary overwrite the address specified above, so you won't be able to use anything that stored in said address. Unless you know what are you doing, leaving it blank is recommended.


To draw on the canvas, you will need to use the provided functions. It's very similar to TIC's fucntions such as `cls`, `circ`, and `rect` (more functions comming soon), just add `fog.` in front and you are drawing to the canvas.
