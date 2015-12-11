/c global.gamePrint = function (text)
	game.player.print(tostring(text))
end

global.print_all = function ( t )  
    local print_r_cache={}
    local function sub_print_r(t,indent)
        if (print_r_cache[tostring(t)]) then
            global.gamePrint(indent.."*"..tostring(t))
        else
            print_r_cache[tostring(t)]=true
            if (type(t)=="table") then
                for pos,val in pairs(t) do
                    if (type(val)=="table") then
                        global.gamePrint(indent.."["..pos.."] => "..tostring(t).." {")
                        sub_print_r(val,indent..string.rep(" ",string.len(pos)+8))
                        global.gamePrint(indent..string.rep(" ",string.len(pos)+6).."}")
                    elseif (type(val)=="string") then
                        global.gamePrint(indent.."["..pos..'] => "'..val..'"')
                    else
                        global.gamePrint(indent.."["..pos.."] => "..tostring(val))
                    end
                end
            else
                global.gamePrint(indent..tostring(t))
            end
        end
    end
    if (type(t)=="table") then
        global.gamePrint(tostring(t).." {")
        sub_print_r(t,"  ")
        global.gamePrint("}")
    else
        sub_print_r(t,"  ")
    end
end

p = global.print_all

---------------------
surface.create_entity forces a minimap update, only works if world size is infinite 


/c p(game.player.surface.name)

/c game.player.print( )

/c for i, p in pairs(game.surfaces) do game.player.print("sdf") end

/c game.player.print(type(game.surfaces))

/c for k,v in ipairs(global) do
	game.player.print(k ..", "..v)
	end
	
/c for k,v in ipairs(game.surfacs) do
game.player.print(k ..", "..v)
end

/c	if next(global) == nil then
   game.player.print("empty")
end

/c game.player.print(tostring(next(global)))

/c  game.player.print(tostring(global["nesttEntities"]))
	


/c game.create_surface("pocket1", {width = 16, height = 1000})

/c game.player.print(game.player.surface.name)

/c game.player.print(type (game.player.surface))

/c game.player.print(game.surfaces["mars"].name)

/c gameprint = game.player.print

/c  game.player.print(type(game.player.force))

/c  game.player.print(type(game.player))

/c for i,line in ipairs(game.surfaces) do
     game.player.print(1)
   end
	
	game.local_player.color = {g=0,b=0,r=0,a=.9}

/c game.player.driving = false	


/c game.player.insert{name="concrete",count=100}

/c script.on_event(defines.events.on_tick, function(event) game.player.surface.set_tiles{{name = "dirt", position = {x = game.player.position.x + 1, y = game.player.position.y}}}
end
)

/c game.player.surface.set_tiles{{name = "train-floor", position = {x = game.player.position.x + 2, y = game.player.position.y}}}

/c game.player.surface.set_tiles{{name = "train-floor", position = {x = game.player.position.x + 2, y = game.player.position.y}}}

/c t = debug.getinfo(game.player.surface.set_tiles)



/c script.on_event(defines.events.on_tick, function(event)
   
 end)

/c game.player.print(tostring(game.surfaces["pocket"].get_tile(1,1).name))

/c game.player.print (game.player.position.x .. " , " .. game.player.position.y)

/c game.players[1].diving = false

/c game.player.print(game.player.vehicle.name)

/c global.myPlane = game.player.vehicle

/c game.player.print (tostring(global.myPlane == game.player.vehicle))

/c game.player.print (type(game.get_surface(1).get_chunks))

/c for i,line in ipairs(global) do
     game.player.print(1)
   end

/c for k,v in pairs(game.player.force) do
  game.player.print(k)
end
	
/c game.player.insert{name="gunship",count=1}
	
/c game.player.teleport({0, 0}, game.surfaces["mars"])

/c game.create_surface("pocket", {width = 10, height = 10})
/c game.player.teleport({0, 0}, game.surfaces["pocket"])

/c game.player.teleport({0, 0}, game.surfaces["nauvis"])

/c game.players[1].gui.top.add{type = "flow", name = "Example_Flow1", direction = "horizontal"} 

/c game.players[1].gui.top.Example_Flow1.add{type = "label", caption = "Example Label"}

/c script.on_event(defines.events.on_gui_click, function(event)
   if (event.element.name == "Example_Button") then
	if (game.player.surface.name == "nauvis") then
     game.player.teleport({0, 0},game.surfaces["pocket"])
	else
	 game.player.teleport({0, 0},game.surfaces["nauvis"])
	 end
   end
 end)

/c game.players[1].gui.top.Example_Flow.add{type = "button", caption = "Example Button1"}

/c game.player.gui.top.Example_Flow.destroy()

/c for y=-2,2 do 
     for x=-2,2 do 
       game.surfaces.nauvis.create_entity({
           name="stone",
           amount=5000,
           position={game.player.position.x+x,game.player.position.y+y}
         }) 
     end 
   end
   
/c game.player.surface.create_entity({
           name="stone",
           amount=5000,
           position={game.player.position.x,game.player.position.y}
         }) 
   
SimpleClass = {}
SimpleClass_mt = { __index = SimpleClass }

-- This function creates a new instance of SimpleClass
--
function SimpleClass:create()
    local new_inst = {}    -- the new instance
    setmetatable( new_inst, SimpleClass_mt ) -- all instances share the same metatable
    return new_inst
end

-- Here are some functions (methods) for SimpleClass:

function SimpleClass:className()
    print( "SimpleClass" )
end

function SimpleClass:doSomething()
    self.className()
end

SubClass = inheritsFrom( SimpleClass )

function SubClass:className() print( "SubClass" ) end

sub = SubClass:create()

--this creates a 10 * 10 area
/c setTiles(game.player.surface, {left_top={x=-5, y=-5}, right_bottom={x=4,y=4}},"concrete")
/c print_all(game.player.surface.find_entities{{-10, -10}, {10, 10}})

function setTiles(surface,area,tileName)
	if not surface then printErr("chunkGen:setTiles not a valid surface") return nil end
	local newTiles = {}
	for x, y in iarea(area) do
		table.insert(newTiles, {name = tileName, position = {x, y}})
	end
	surface.set_tiles(newTiles)
end


/c function removeEntities(surface,area)
	local ents = surface.find_entities(area)
	for i, entity in ipairs(ents) do
		
		if entity.type ~= "player" then
			entity.destroy()
		end
	end
end

/c removeEntities(game.player.surface,{{-10, -10}, {10, 10}})


/c my_event = script.generate_event_name()



/c game.player.selected.amount = 90

/c game.player.selected.force = game.forces.player

/c game.player.selected.damage({Amount = 1, force = game.player.force})

/c game.player.surface.create_entity{name = "copper-ore-particle", position = game.player.selected.position, movement = {0.1,0.1},height = 0.01,vertical_speed = 0.05,frame_speed= 1 }

/c game.player.surface.create_entity{name = "leaf-particle", position = game.player.selected.position}

/c p(game.player.vehicle.orientation)


/c game.player.surface.create_entity{name = "mining-beam", position = game.player.selected.position, source = game.player.selected, source_position = game.player.selected.position, target = game.player.vehicle }



/c e = game.player.surface.create_entity{
				name = "steel-chest",
				position = {-6.5,-18.5},
				force = game.forces.player,
				destructible = false,
				minable = false
			}
			
			
			
/c beam = game.player.surface.create_entity({name = "mining-beam", position = {0,0}, source = game.player.character, target = game.player.selected})


/c p(game.player.surface.find_entity("mining-beam",game.player.position))