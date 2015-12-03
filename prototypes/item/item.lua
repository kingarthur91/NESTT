data:extend(
  {
    {
      type = "item",
      name = "nestt-locomotive",
      icon = "__NESTT__/graphics/icons/nestt-locomotive.png",
      flags = {"goes-to-quickbar"},
      subgroup = "transport",
      order = "a[train-system]-e[nestt-locomotive]",
      place_result = "nestt-locomotive",
      stack_size = 5
    },
	{
      type = "item",
      name = "nestt-wagon",
      icon = "__NESTT__/graphics/icons/nestt-wagon.png",
      flags = {"goes-to-quickbar"},
      subgroup = "transport",
      order = "a[train-system]-e[nestt-wagon]",
      place_result = "nestt-wagon",
      stack_size = 5
    },
  })
