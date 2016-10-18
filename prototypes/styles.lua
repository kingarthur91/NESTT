data:extend(
  {
    {
      type = "font",
      name = "nestt-small",
      from = "default",
      size = 13
    },
    {
      type ="font",
      name = "nestt-small-bold",
      from = "default-bold",
      size = 13
    }
  }
)

data.raw["gui-style"].default["nestt_label"] =
  {
    type = "label_style",
    font = "nestt-small",
    font_color = {r=1, g=1, b=1},
    top_padding = 0,
    bottom_padding = 0
  }

data.raw["gui-style"].default["nestt_textfield"] =
  {
    type = "textfield_style",
    left_padding = 3,
    right_padding = 2,
    minimal_width = 60,
    font = "nestt-small"
  }

data.raw["gui-style"].default["nestt_textfield_small"] =
  {
    type = "textfield_style",
    left_padding = 3,
    right_padding = 2,
    minimal_width = 30,
    font = "nestt-small"
  }
data.raw["gui-style"].default["nestt_button"] =
  {
    type = "button_style",
    parent = "button_style",
    font = "nestt-small-bold"
  }
data.raw["gui-style"].default["nestt_checkbox"] =
  {
    type = "checkbox_style",
    parent = "checkbox_style",
    font = "nestt-small",
  }
