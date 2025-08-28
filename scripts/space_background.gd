extends Node2D

@export var STAR_COUNT = 500
@export var SPEED = 7.5

var stars = []
var screen_size

func _ready():
	screen_size = get_viewport_rect().size
	randomize()
	#  stars
	for i in STAR_COUNT:
		stars.append({
			"x": randf_range(-screen_size.x/2, screen_size.x/2),
			"y": randf_range(-screen_size.y/2, screen_size.y/2),
			"z": randf_range(1.0, screen_size.x) # depth
		})
# move stars
func _process(delta):
	for s in stars:
		s["z"] -= SPEED
		if s["z"] <= 0:
			s["x"] = randf_range(-screen_size.x/2, screen_size.x/2)
			s["y"] = randf_range(-screen_size.y/2, screen_size.y/2)
			s["z"] = screen_size.x
	queue_redraw() 
# draw it as Vector2 but 3d 
func _draw():
	var focal_length = screen_size.x / 2.0
	for s in stars:
		var scale = focal_length / s["z"]
		var x = s["x"] * scale + screen_size.x / 2.0
		var y = s["y"] * scale + screen_size.y / 2.0
		var size = (1.0 - s["z"] / screen_size.x) * 3.0
		var alpha = clamp(1.0 - s["z"] / screen_size.x, 0, 1)
		draw_circle(Vector2(x, y), size, Color(1, 1, 1, alpha))
