
local nestt_locomotive = copyPrototype("locomotive", "locomotive", "nestt-locomotive")
nestt_locomotive.icon = "__NESTT__/graphics/icons/nestt-locomotive.png"
nestt_locomotive.icon_size = 32
nestt_locomotive.max_speed = 0.2
nestt_locomotive.max_health = 100000
nestt_locomotive.weight = 2000
nestt_locomotive.friction_force = 0.0015--0.0015
nestt_locomotive.air_resistance = 0.002--0.002
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

nestt_locomotive.resistances =
{
  {
	type = "fire",
	decrease = 15,
	percent = 90
  },
  {
	type = "physical",
	decrease = 15,
	percent = 90
  },
  {
	type = "impact",
	decrease = 70,
	percent = 95
  },
  {
	type = "explosion",
	decrease = 15,
	percent = 90
  },
  {
	type = "acid",
	decrease = 15,
	percent = 90
  }
}
  
local nestt_wagon = copyPrototype("cargo-wagon", "cargo-wagon", "nestt-wagon")
nestt_wagon.icon = "__NESTT__/graphics/icons/nestt-wagon.png"
nestt_wagon.icon_size = 32
nestt_wagon.max_health = 100000
nestt_wagon.weight = 1000
nestt_wagon.friction_force = 0.0015--0.0015
nestt_wagon.air_resistance = 0.002--0.002

nestt_wagon.resistances = nestt_locomotive.resistances

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
      filename = "__NESTT__/graphics/icons/empty.png",
      priority = "very-low",
      width = 1,
      height = 1,
      shift = {0.2, 0}
    }

--local straightRail = copyPrototype("straight-rail", "straight-rail", "straight-rail")
local straightRail = data.raw["straight-rail"]["straight-rail"]
straightRail.flags = {"placeable-neutral", "building-direction-8-way"}

--local curvedRail = copyPrototype("curved-rail", "curved-rail", "curved-rail")
local curvedRail = data.raw["curved-rail"]["curved-rail"]
curvedRail.flags = {"placeable-neutral", "building-direction-8-way"}

--time_to_live = 60 * 60 * 2,

--local smallBiter = copyPrototype("unit", "small-biter", "small-biter")
local smallBiter = data.raw["unit"]["small-biter"]
--smallBiter.time_to_live = 60 * 3
--smallBiter.time_before_removed = 60 * 3
smallBiter.movement_speed = 0.3

local nesttChest = copyPrototype("container", "wooden-chest", "nestt-chest")
nesttChest.inventory_size = 1

data:extend({
	nestt_locomotive, 
	nestt_wagon, 
	mining_beam,
	invisible_chest,
	straightRail,
	curvedRail,
	smallBiter,
	nesttChest,
})


