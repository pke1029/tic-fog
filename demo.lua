-- title:	fog_demo
-- author:	pke1029
-- desc:	Demo for fog, a layer library for TIC-80
-- script:	lua
-- input:	mouse

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
				d = d + 4 * (i - j) + 10
			else
				d = d + 4 * i + 6
			end
		end
	end,
}

function SCN(line)
	local k = line/136
	poke(0x3fc0+24, peek(0x3fc0+6)*(1-k)+peek(0x3fc0+9)*k)
	poke(0x3fc0+25, peek(0x3fc0+7)*(1-k)+peek(0x3fc0+10)*k)
	poke(0x3fc0+26, peek(0x3fc0+8)*(1-k)+peek(0x3fc0+11)*k)
end

math.randomseed(8)

t=0
ma = false
mb = false
zoom = false

stars = {}
for i = 0,30 do
	local x = math.floor(math.random()*240)
	local y = math.floor(math.random()*136)
	local t = math.floor(math.random()*1000)
	table.insert(stars, {x, y, t})
end

function scene1()
	cls(12)
	circ(135, 45, 27, 13)

	fog.cls(8)
	fog.circ(120, 50, 21+(t//100)%2, 15)
	fog.circ(120, 50, 20, 1)
	fog.show(1)

	for i,v in pairs(stars) do
		if v[3] < 60 then
			spr(256+v[3]//15, v[1], v[2], 0)
			v[3] = v[3] + 1
		else
			spr(256, v[1], v[2], 0)
			v[3] = (v[3] + 1) % 1000
		end
	end

end

stars2 = {}
for i = 0,10 do
	local x = math.floor(math.random()*50)
	local y = math.floor(math.random()*136)
	local t = math.floor(math.random()*1000)
	table.insert(stars2, {x, y, t})
end

rabbits = {}
for i = 0,2 do
	local x = math.floor(math.random()*30)
	local y = math.floor(math.random()*30)
	local t = math.floor(math.random()*4)
	local d = math.floor(math.random()*2)
	table.insert(rabbits, {x, y, t, d})
end

grass = {}
for i = 0,30 do
	local x = math.floor(math.random()*240)
	local y = math.floor(math.random()*150)
	table.insert(grass, {x, y})
end

function randomWalk(r)
	local prob = 0.5
	-- stand still
	if math.random() < 0.8 then 
		if r[3] < 3 then
			r[3] = r[3] + 1
			return
		end 
	end
	-- move x
	if math.random() < prob then
		r[1] = r[1] + 1
		r[4] = 1
	else
		r[1] = r[1] - 1
		r[4] = 0
	end
	-- move y
	if math.random() < prob then
		r[2] = r[2] + 1
	else
		r[2] = r[2] - 1
	end
	r[3] = 0
end

function scene2(mx, my)

	local x = math.floor(mx/3)
	local y = math.floor(my/3)

	cls(12)
	circ(-x+150, -y+70, 140, 13)
	-- circ(-x+160, -y+60, 50, 13)

	for i,v in pairs(grass) do
		spr(289, v[1]-x, v[2]-y+10, 0)
	end

	fog.cls(8)
	fog.circ(-x+100, -y+150, 155, 3)
	fog.circ(-x+100, -y+150, 150, 1)
	fog.show(1)

	for i,v in pairs(stars2) do
		if v[3] < 60 then
			spr(256+v[3]//15, v[1]-x+250, v[2]-y, 0)
			v[3] = v[3] + 1
		else
			spr(256, v[1]-x+250, v[2]-y, 0)
			v[3] = (v[3] + 1) % 1000
		end
	end

	for i,v in pairs(rabbits) do
		spr(320+v[4]*16+v[3], v[1]-x+130, v[2]-y+50, 0)
	end

	if t%60 == 0 then
		for i,v in pairs(rabbits) do
			randomWalk(v)
		end
	end

	table.sort(rabbits, function(r,s) return r[2] < s[2] end)

	fog.cls()
	fog.circ(mx, my, 70, 1)
	fog.show(1)
end

function TIC()

	local mx, my, mb = mouse()
	if not (ma or (not mb or false)) then
		zoom = not zoom
	end
	ma = mb

	if not zoom then
		scene1()
	else
		scene2(mx, my)
	end

	t=t+1
end
