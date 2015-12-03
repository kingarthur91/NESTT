--[[--
Simple logger by Dark
--]]--
require "defines"

local _M = {}
local Logger = {prefix='log_'}
Logger.__index = Logger

function Logger:log(str)
  local run_time_s = math.floor(game.tick/60)
  local run_time_minutes = math.floor(run_time_s/60)
  local run_time_hours = math.floor(run_time_minutes/60)
  self.log_buffer[#self.log_buffer + 1] = string.format("%02d:%02d:%02d: %s\r\n", run_time_hours, run_time_minutes % 60, run_time_s % 60, str)
end

function Logger:logTable(t,level)
	local function shortLog(str)
		self.log_buffer[#self.log_buffer + 1] = str .. "\r\n"
	end
	local log_r_cache={}
	level = level or 20 --max recursion level, set this to -1 for infinite recursion, will crash if table has loops
    local function sub_log_r(t,indent,level)
		if level == 0 then return end
        if (log_r_cache[tostring(t)]) then
            shortLog(indent.."*"..tostring(t))
        else
            log_r_cache[tostring(t)]=true
            if (type(t)=="table") then
                for pos,val in pairs(t) do
                    if (type(val)=="table") then
                        shortLog(indent.."["..pos.."] => "..tostring(t).." {")
                        sub_log_r(val,indent..string.rep(" ",string.len(pos)+8),level-1)
                        shortLog(indent..string.rep(" ",string.len(pos)+6).."}")
                    elseif (type(val)=="string") then
                        shortLog(indent.."["..pos..'] => "'..val..'"')
                    else
                        shortLog(indent.."["..pos.."] => "..tostring(val))
                    end
                end
            else
                shortLog(indent..tostring(t))
            end
        end
    end
    if (type(t)=="table") then
        shortLog(tostring(t).." {")
        sub_log_r(t,"  ",level)
        shortLog("}")
    else
        sub_log_r(t,"  ")
    end
end

function Logger:dump(file_name)
  if #self.log_buffer == 0 then return false end
  file_name = file_name or "logs/"..self.prefix..game.tick..".log"
  game.write_file(file_name, table.concat(self.log_buffer))
  self.log_buffer = {}
  return true
end


function _M.new_logger()
  local temp = {log_buffer = {}}
  return setmetatable(temp, Logger)
end

return _M