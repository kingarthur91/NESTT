
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

  
  
data:extend({nestt_locomotive,nestt_wagon})


