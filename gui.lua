gui = {

styleprefix = "nestt_",

defaultStyles = {
  label = "label",
  button = "button",
  checkbox = "checkbox"
},

bindings = {},

callbacks = {},

add = function(parent, e, bind)
  local gtype, name = e.type, e.name
  if not e.style and gui.defaultStyles[gtype] then
	e.style = gui.styleprefix..gtype
  end
  if bind then
	if e.type == "checkbox" then
	  if e.state == nil then
		e.state = false
	  end
	  if type(bind) == "string" then
		e.state = Settings.loadByPlayer(parent.gui.player)[e.name]
	  else
		e.state = false
		gui.callbacks[e.name] = bind
	  end
	end
  end
  local ret = parent.add(e)
  if bind and e.type == "textfield" then
	ret.text = bind
  end
  if e.type == "checkbox" and e.state == nil then
	e.state = false
  end
  return ret
end,

addButton = function(parent, e, bind)
  e.type = "button"
  if bind then
	gui.callbacks[e.name] = bind
  end
  return gui.add(parent, e, bind)
end,

createGui = function(player)
	if player.gui.left.nestt ~= nil then return end
	local left = player.gui.left
	local nestt = gui.add(left, {type="frame", direction="vertical", name="nestt"})
	local rows = gui.add(nestt, {type="table", name="rows", colspan=1})
	
	local span = 3
	if debugButton then
		span = 4
	end
	local buttons = gui.add(rows, {type="table", name="buttons", colspan=span})
	gui.addButton(buttons, {name="enterExit", caption="Enter/Exit"}, guiScripts.enterExit)

	if debugButton then
		gui.addButton(buttons,{name="debug", caption="D"},gui.debugInfo)
	end		
end,

destroyGui = function(player)
	if player.valid then
		if player.gui.left.nestt == nil then return end
	player.gui.left.nestt.destroy()
	end
end,

createProgressBar = function(player)
	if player.gui.left.surfProg ~= nil then return end
	local left = player.gui.left
	local surfProg = gui.add(left, {type="frame", direction="vertical", name="surfProg",caption = "surface gen progress"})
	local prog =  gui.add(surfProg, {type="progressbar", name="prog",caption = "progress", size=100, value = 0})
	return prog
end,

destroyProgressBar = function(player)
	if player.gui.left.surfProg == nil then return end
	player.gui.left.surfProg.destroy()
end,

debugInfo = function(event, farl, player)
	local index = event.player_index
	local player = game.players[index]
	--debugPrint("debug")
end,

onguiClick = function(event)
	local name = event.element.name
	if gui.callbacks[name] then
		return gui.callbacks[name](event)
	end
end,

}
