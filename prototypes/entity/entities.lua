
local nestt_locomotive = copyPrototype("locomotive", "diesel-locomotive", "nestt-locomotive")
nestt_locomotive.icon = "__NESTT__/graphics/icons/nestt-locomotive.png"
nestt_locomotive.max_speed = 0.8
nestt_locomotive.pictures.filenames =
  {
    "__NESTT__/graphics/entity/nestt-locomotive/nestt-locomotive-01.png",
    "__NESTT__/graphics/entity/nestt-locomotive/nestt-locomotive-02.png",
    "__NESTT__/graphics/entity/nestt-locomotive/nestt-locomotive-03.png",
    "__NESTT__/graphics/entity/nestt-locomotive/nestt-locomotive-04.png",
    "__NESTT__/graphics/entity/nestt-locomotive/nestt-locomotive-05.png",
    "__NESTT__/graphics/entity/nestt-locomotive/nestt-locomotive-06.png",
    "__NESTT__/graphics/entity/nestt-locomotive/nestt-locomotive-07.png",
    "__NESTT__/graphics/entity/nestt-locomotive/nestt-locomotive-08.png"
  }
  
local nestt_wagon = copyPrototype("cargo-wagon", "cargo-wagon", "nestt-wagon")
nestt_wagon.icon = "__NESTT__/graphics/icons/nestt-wagon.png"

local mining_beam = copyPrototype("beam", "electric-beam", "mining-beam")
mining_beam.damage_interval = 2000
mining_beam.action.action_delivery.target_effects[1].damage.amount = 0
mining_beam.flags = {"not-on-map","placeable-off-grid"}

local invisible_chest = copyPrototype("container", "steel-chest", "invisible-chest")
invisible_chest.minable = nil
--"placeable-neutral","placeable-off-grid",
invisible_chest.flags = {"not-on-map"}
invisible_chest.max_health = 2000
invisible_chest.collision_box = {{0, 0}, {0, 0}}
invisible_chest.selection_box = {{0, 0}, {0, 0}}
invisible_chest.selectable_in_game = false
invisible_chest.destructible = false
invisible_chest.collision_mask = {}
invisible_chest.fast_replaceable_group = nil
invisible_chest.inventory_size = 48
invisible_chest.picture =
    {
      filename = "__base__/graphics/entity/steel-chest/steel-chest.png",
      priority = "very-low",
      width = 0,
      height = 0,
      shift = {0.2, 0}
    }


data:extend({
	nestt_locomotive, 
	nestt_wagon, 
	mining_beam,
	invisible_chest
})


