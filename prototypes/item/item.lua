data:extend(
  {
    {
      type = "item",
      name = "nestt-locomotive",
      icon = "__NESTT__/graphics/icons/nestt-locomotive.png",
      icon_size = 32,
      flags = {},
      subgroup = "transport",
      order = "a[train-system]-e[nestt-locomotive]",
      place_result = "nestt-locomotive",
      stack_size = 5
    },
    {
      type = "item",
      name = "nestt-wagon",
      icon = "__NESTT__/graphics/icons/nestt-wagon.png",
      icon_size = 32,
      flags = {},
      subgroup = "transport",
      order = "a[train-system]-e[nestt-wagon]",
      place_result = "nestt-wagon",
      stack_size = 5
    },
    {
      type = "item",
      name = "nestt-chest",
      icon = "__base__/graphics/icons/wooden-chest.png",
      icon_size = 32,
      flags = {},
      subgroup = "storage",
      order = "a[items]-b[nestt-chest]",
      place_result = "nestt-chest",
      stack_size = 50
    }
  }
)
