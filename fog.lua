-- title:	fog
-- author:	pke1029
-- desc:	Layer library for TIC-80
-- script:	lua

-- DOC --------------------------------

--[[

Free to use, creadit appreciated :)

Ever wanted to draw anti-circle? Or
somekind of layering system in TIC? If 
so, this is the library for you! Simply 
copy the fog table and you are set to 
go!

FOG uses the lower half of the memory 
of MAP on the vram (0xbfc0 up to but 
not including 0xff80) as a second 
screen/canvas. You are free to draw on 
the canvas and whenever one wants to 
display the content of the canvas, one
simply call the function 'fog.show()' 
with the optional parameter of a 
'colorkey' (the color you'd like to be 
invinsible). It's as simple as that.

WARNING: It will temporary overwrite 
the address specified above, so you 
won't be able to use anything that 
stored in said address. Unless you know 
what are you doing, leaving it blank is 
recommended.

To draw on the canvas, you will need to 
use the provided functions. It's very 
similar to TIC's fucntions such as cls, 
circ, and rect (more functions comming 
soon), just add 'fog.' in front and you 
are drawing to the canvas.

                 -- pke1029, 06-08-2019

Future update will be made at 
https://github.com/pke1029/tic-fog

]]

---------------------------------------

fog = {

	-- 8 bit address 0xbfc0
	-- 4 bit address 0x17f80

	math = {
		between = function(x, a, b)
			return x >= a and x < b
		end,

		clamp = function(x, a, b)
			if fog.math.between(x, a, b) then return x end
			if x < a then return a end
			if x >= b then return b end
		end
	},

	cls = function(color)
		color = color or 0
		local val = color + (color << 4)
		memset(0xbfc0, val, 16320)
	end,

	show = function(colorkey)
		if colorkey == nil or colorkey == -1 then
			memcpy(0, 0xbfc0, 16320)
			return
		else
			for i = 0,32639 do
				local col = peek4(0x17f80+i)
				if colorkey ~= col then
					poke4(i, col)
				end
			end
		end
	end,

	prtSc = function()
		memcpy(0xbfc0, 0, 16320)
	end,

	hLine = function(x, y, w, color)
		if fog.math.between(y, 0, 136) then
			for i = fog.math.clamp(x, 0, 240),fog.math.clamp(x+w-1, 0, 239) do
				poke4(0x17f80+y*240+i, color)
				-- trace(i)
			end
		end
	end,

	rect = function(x, y, w, h, color)
		for j = fog.math.clamp(y, 0, 136),fog.math.clamp(y+h-1, 0, 135) do
			for i = fog.math.clamp(x, 0, 240),fog.math.clamp(x+w-1, 0, 239) do
				poke4(0x17f80+j*240+i, color)
			end
		end
	end,

	circ = function(x, y, r, color)
		local i = 0
		local j = r
		local d = 3 - 2 * r
		while j >= i do
			fog.hLine(x-i, y+j, 2*i+1, color)
			fog.hLine(x-i, y-j, 2*i+1, color)
			fog.hLine(x-j, y+i, 2*j+1, color)
			fog.hLine(x-j, y-i, 2*j+1, color)
			i = i + 1
			if d > 0 then
				j = j - 1
				d = d + 4 * (i - j) + 2
			else
				d = d + 4 * i + 2
			end
		end
	end,

	--TODO: line, tri, spr, multiply, map

}