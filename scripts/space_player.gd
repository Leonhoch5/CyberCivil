extends CharacterBody2D

@export var follow_speed: float = 10.0
@export var curve_stregth: float = -0.001
@export var base_y: float = 400.0
@export var dash_distance: float = 100.0
@export var dash_time: float = 0.2
@export var radius: float = 20.0  
@export var max_rotation_degrees: float = 15.0  
@export var rotation_speed: float = 5.0 

var center_x: float
var anchor_pos: Vector2
var dash_offset: float = 0.0
var dash_dir: int = 0
var dash_timer: float = 0.0
var target_rotation: float = 0.0
var previous_x: float = 0.0

func _ready():
	center_x = get_viewport_rect().size.x / 2
	previous_x = position.x


func _physics_process(delta):
	# mouse follow
	var mouse_x = get_viewport().get_mouse_position().x
	var new_x = lerp(position.x, mouse_x, follow_speed * delta)
	var offset_x = new_x - center_x
	var new_y = curve_stregth * pow(offset_x, 2) + base_y
	anchor_pos = Vector2(new_x, new_y)

	var movement_direction = sign(new_x - previous_x)
	previous_x = new_x
	
	# Dash 
	if dash_timer > 0:
		dash_timer -= delta
		var t = 1.0 - (dash_timer / dash_time)
		var dash_curve = sin(t * PI)
		dash_offset = dash_dir * dash_distance * dash_curve
		
		target_rotation = deg_to_rad(max_rotation_degrees * -dash_dir)
	else:
		dash_offset = 0.0
		dash_dir = 0
		
		if movement_direction != 0:
			target_rotation = deg_to_rad(max_rotation_degrees * -movement_direction)
		else:
			target_rotation = 0.0

	rotation = lerp(rotation, target_rotation, rotation_speed * delta)

	position = anchor_pos + Vector2(dash_offset, 0)

	# input
	if dash_timer <= 0:
		if Input.is_action_just_pressed("right"):
			dash_dir = -1
			dash_timer = dash_time
		elif Input.is_action_just_pressed("left"):
			dash_dir = 1
			dash_timer = dash_time
