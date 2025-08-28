extends Node2D

@export var METEOR_COUNT = 20
@export var SPEED = 20.0
@export var METEOR_SIZE = 32  # Perfect for pixel art

var meteors = []
var screen_size
var Z_HIT_THRESHOLD = 650.0

func _ready():
	screen_size = get_viewport_rect().size
	randomize()

	# create meteors with unique textures
	for i in METEOR_COUNT:
		meteors.append({
			"x": randf_range(-screen_size.x/2, screen_size.x/2),
			"y": randf_range(-screen_size.y/2, screen_size.y/2),
			"z": randf_range(1.0, screen_size.x),
			"hit": false,
			"tex": generate_meteor_texture(METEOR_SIZE)
		})

func _process(delta):
	var focal_length = screen_size.x / 2.0
	var player = get_node("/root/SpaceTraining/Spaceship")
	var player_z = 0  

	for m in meteors:
		m["z"] -= SPEED
		if m["z"] <= 0:
			_reset_meteor(m)

		# project position
		var scale = focal_length / m["z"]
		var meteor_pos = Vector2(
			m["x"] * scale + screen_size.x / 2.0,
			m["y"] * scale + screen_size.y / 2.0
		)
		var meteor_radius = (3.0 - m["z"]/screen_size.x) * 5.0

		if abs(m["z"] - player_z) < Z_HIT_THRESHOLD:
			if meteor_pos.distance_to(player.position) < (meteor_radius + player.radius):
				print("Player hit!")
				m["hit"] = true

	queue_redraw()

func _draw():
	var focal_length = screen_size.x / 2.0
	for m in meteors:
		var scale = focal_length / m["z"]
		var x = m["x"] * scale + screen_size.x / 2.0
		var y = m["y"] * scale + screen_size.y / 2.0
		var size = (6.0 - m["z"] / screen_size.x) * 20.0
		var alpha = clamp(1.0 - m["z"] / screen_size.x, 0, 1)

		var tex: Texture2D = m["tex"]
		if tex:
			var draw_size = Vector2(size, size)
			var pos = Vector2(x, y) - draw_size / 2.0
			# green tint if hit
			var tint = Color(0.2, 1.0, 0.2, alpha) if m["hit"] else Color(1, 1, 1, alpha)
			draw_texture_rect(tex, Rect2(pos, draw_size), false, tint)
		else:
			draw_circle(Vector2(x, y), size / 2.0, Color(0.8, 0.3, 0.1, alpha))

func _reset_meteor(m):
	m["x"] = randf_range(-screen_size.x/2, screen_size.x/2)
	m["y"] = randf_range(-screen_size.y/2, screen_size.y/2)
	m["z"] = screen_size.x
	m["hit"] = false
	m["tex"] = generate_meteor_texture(METEOR_SIZE)  # new look when respawned

# --- Pixel Art Generation ---

func generate_meteor_texture(size: int = 32) -> Texture2D:
	var img = generate_meteor_image(size)
	return ImageTexture.create_from_image(img)

func generate_meteor_image(size: int = 32, seed: int = randi()) -> Image:
	var rng = RandomNumberGenerator.new()
	rng.seed = seed

	var img = Image.create(size, size, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	
	#color palette
	var colors = [
		Color(0.22, 0.28, 0.33),  # Dark bluish-gray
		Color(0.35, 0.40, 0.45),  # Medium bluish-gray
		Color(0.50, 0.55, 0.60),  # Light bluish-gray
		Color(0.40, 0.36, 0.32),  # Dark brownish-gray
		Color(0.58, 0.53, 0.48)   # Light brownish-gray
	]
	
	var center = Vector2(size / 2, size / 2)
	var base_radius = size / 2 - 2  
	
	var points = []
	var num_points = 8 + rng.randi() % 5 
	
	for i in range(num_points):
		var angle = 2 * PI * i / num_points
		var variance = 0.7 + rng.randf() * 0.6 
		var point_radius = base_radius * variance
		var point = center + Vector2(cos(angle) * point_radius, sin(angle) * point_radius)
		points.append(point)
	
	fill_polygon(img, points, colors[0])
	
	var num_craters = 2 + rng.randi() % 3
	for i in range(num_craters):
		var crater_center = Vector2(
			rng.randi_range(4, size - 4),
			rng.randi_range(4, size - 4)
		)
		
		if is_point_in_polygon(crater_center, points):
			var crater_radius = 2 + rng.randi() % 3
			var crater_points = []
			var crater_point_count = 5 + rng.randi() % 4
			
			for j in range(crater_point_count):
				var angle = 2 * PI * j / crater_point_count
				var variance = 0.8 + rng.randf() * 0.4
				var point_radius = crater_radius * variance
				var point = crater_center + Vector2(cos(angle) * point_radius, sin(angle) * point_radius)
				crater_points.append(point)
			
			fill_polygon(img, crater_points, colors[0].darkened(0.3))
	
	for i in range(size * 2):
		var x = rng.randi_range(1, size - 2)
		var y = rng.randi_range(1, size - 2)
		
		if is_point_in_polygon(Vector2(x, y), points):
			var current_color = img.get_pixel(x, y)
			if current_color.a > 0:  
				# Randomly lighten or darken some pixels
				if rng.randf() < 0.3:
					var variation = 1.0 + (rng.randf() - 0.5) * 0.4
					var new_color = Color(
						clamp(current_color.r * variation, 0, 1),
						clamp(current_color.g * variation, 0, 1),
						clamp(current_color.b * variation, 0, 1)
					)
					img.set_pixel(x, y, new_color)
	
	return img

func fill_polygon(img: Image, points: Array, color: Color):

	var min_x = points[0].x
	var max_x = points[0].x
	var min_y = points[0].y
	var max_y = points[0].y
	
	for point in points:
		min_x = min(min_x, point.x)
		max_x = max(max_x, point.x)
		min_y = min(min_y, point.y)
		max_y = max(max_y, point.y)
	
	for y in range(max(0, floor(min_y)), min(img.get_height(), ceil(max_y))):
		for x in range(max(0, floor(min_x)), min(img.get_width(), ceil(max_x))):
			if is_point_in_polygon(Vector2(x, y), points):
				img.set_pixel(x, y, color)

func is_point_in_polygon(point: Vector2, polygon: Array) -> bool:
	var inside = false
	var j = polygon.size() - 1
	
	for i in range(polygon.size()):
		if ((polygon[i].y > point.y) != (polygon[j].y > point.y)) and \
		   (point.x < (polygon[j].x - polygon[i].x) * (point.y - polygon[i].y) / (polygon[j].y - polygon[i].y) + polygon[i].x):
			inside = not inside
		j = i
	
	return inside
