local train_floor = copyPrototype("tile", "concrete", "train-floor")

train_floor.minable = nil
train_floor.map_color={r=100, g=100, b=100}
train_floor.decorative_removal_probability = nil
train_floor.layer = 59 --I think higher layer tiles can replace lower ones
data:extend({train_floor})