--[[
by xiaohong 12/1/2015
----------WHAT THIS IS----------

this is a script for factorio 0.12.17
It adds psuedo closure function behavior that persists across save/loads

the global table can save functions, tables and built-in factorio objects, functions with closures will NOT work however as seen here: http://www.factorioforums.com/wiki/index.php?title=Lua/Data_Lifecycle#global

with this script you can have behavior almost identical to closures

----------HOW TO USE----------
to initialize call pClosureInit() in script.on_init() or script.on_load()

to add a function:
fName = global.pClosure.add(someFunction, upval1, upval2, ...)

note: fName is a string that should be saved for later use and is guaranteed to be unique.

to call the function:
global.pClosure.call(fName, arg1, arg2, ...)

to delete the function:
global.pClosure.delete(fName)

----------IMPORTANT----------

this will not automatically work for your functions, you must change them so that they do not contain real closures, it is not hard to remove closures, you simply pass the "upvalues" on as additional parameters to your function, they should come before the normal arguments

also note that since the global table is not accessible (i may be wrong) before script.on_init()/script.on_load() you should only use this script after pClosureInit() is called in on_init()/on_load()

----------BAD EXAMPLE----------

--This is an example of what not to do, b is a function with a normal closure, this will not work for save/loads, it will raise an error---
function SomeFunction()
	local upval = "_world"
	function b(arg1)
		game.player.print(arg1 .. upval)
	end
	global.b = b --save the function to global
end

--call b before save/load
SomeFunction()
global.b("hello")

--result: "hello_world"

--save/load game then call b()
global.b("hello")

--result: error

--if you save b in global and call it after a load, it will say something like attempting to access nil value upval, or discard upval, so it will either crash or print out "hello" instead of the expected "hello_world"

----------GOOD EXAMPLE----------

--we change the above code to work on save/load
function SomeFunction()
	local upval = "_world"
	function b(upval,arg1) --upval was an upvalue for b so we pass it in explicitly, 
		game.player.print(arg1 .. upval)
	end
	
	fName = global.pClosure.add(b, upval) --this saves upval so that it will not be nil after load. IMPORTANT: make sure that you are still in the closure, see that function a has not ended. Also don't try to add arg1 as that doesn't make sense
	
	global.fName = fName --you should save fName since you will need it to access the function
end

--call before save/load
SomeFunction()
global.pClosure.call(fName,"hello")

--result: "hello_world"

--save/load game then call
global.pClosure.call(fName,"hello")

--result: error fName is nil
--the correct call
global.pClosure.call(global.fName,"hello")

--result: "hello_world"

--delete the function
global.pClosure.delete(global.fName)
global.fName = nil --not needed anymore

----------ADVANCED EXAMPLE----------
if the upvalues themselves are functions with closures, you should also turn them into pClosure strings and pass them on, then call them inside the function with global.pClosure.call, not tested, but should work

function SomeFunction()
	local upvalA = "upA"
	local function funA(upvalA,argA) 
		game.player.print(argA .. upval)
	end
	
	global.fNameA = global.pClosure.add(funA, upvalA)
	
	--pass in fNameA as a string, and also argA will be needed if funA takes arguments other than the upvalues
	
	local upValB = "upB"
	function funB(fNameA,upValB,argA,argB)  
		global.pClosure.call(fNameA,argA)
		game.player.print(argB .. upValB)
	end
  
	global.fNameB = global.pClosure.add(funB, global.fNameA, upValB) 
	--upvalA was already saved before 
end

--to call
SomeFunction()
argA = "hello_"
argB = "world_"
global.pClosure.call(global.fNameB,argA,argB)

result:
hello_upA
world_upB

--delete all
global.pClosure.delete(global.fNameA)
global.pClosure.delete(global.fNameB)
global.fNameA = nil 
global.fNameB = nil

----------NOTES----------

I am aware of the __call metamethod, but since global doesn't save metamethods, this would need to be reinitialized every time, would add a bit of syntactical sugar but would mean more work

--]]

--Initialize pClosure, calling more than once will not break anything
function pClosureInit()
	if not global then error("global is not available, you should call pClosureInit() in script.on_init or on_load") end
	global.pClosure = global.pClosure or {}
	if not global.pClosure.add then
		global.pClosure.add = function (f,...)
		local i = 1
		local fName = ""
		local arg = {...}
		repeat
			fName = tostring(f) .. "_" .. i
			i = i + 1
		until global.pClosure[fName] == nil
		global.pClosure[fName] = {func = f,upvals = arg}
		return fName
		end
	end
	
	if not global.pClosure.call then
		global.pClosure.call = function(fName,...)
			local arg = {...}
			local func = global.pClosure[fName].func
			local upvals = global.pClosure[fName].upvals or {}
			func(table.unpack(upvals),table.unpack(arg))
		end
	end
	
	if not global.pClosure.delete then 
		global.pClosure.delete = function(fName)
			global.pClosure[fName] = nil
		end
	end
end

