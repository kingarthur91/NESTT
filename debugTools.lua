local gamePrint = function (text)
	--game.player.print(tostring(text))
	game.print(tostring(text))
end


local print_all = function ( t )  
    local print_r_cache={}
    local function sub_print_r(t,indent)
        if (print_r_cache[tostring(t)]) then
            gamePrint(indent.."*"..tostring(t))
        else
            print_r_cache[tostring(t)]=true
            if (type(t)=="table") then
                for pos,val in pairs(t) do
                    if (type(val)=="table") then
                        gamePrint(indent.."["..pos.."] => "..tostring(t).." {")
                        sub_print_r(val,indent..string.rep(" ",string.len(pos)+8))
                        gamePrint(indent..string.rep(" ",string.len(pos)+6).."}")
                    elseif (type(val)=="string") then
                        gamePrint(indent.."["..pos..'] => "'..val..'"')
                    else
                        gamePrint(indent.."["..pos.."] => "..tostring(val))
                    end
                end
            else
                gamePrint(indent..tostring(t))
            end
        end
    end
    if (type(t)=="table") then
        gamePrint(tostring(t).." {")
        sub_print_r(t,"  ")
        gamePrint("}")
    else
        sub_print_r(t,"  ")
    end
end

debugPrint = function(o)
	if debug_enabled then 
		print_all(o)
		print_all(debug.traceback())
	end
end

printErr = function(o)
	if printErr_enabled then 
		print_all(o)
		print_all(debug.traceback())
	end
end

print = print_all
global.print = print