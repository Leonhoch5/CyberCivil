extends CharacterBody2D

@export var speed: float = 200.0

func _physics_process(delta: float) -> void:
	var direction := Vector2.ZERO

	# Movement input
	if Input.is_action_pressed("up"):
		direction.y -= 1
	if Input.is_action_pressed("down"):
		direction.y += 1
	if Input.is_action_pressed("left"):
		direction.x -= 1
	if Input.is_action_pressed("right"):
		direction.x += 1

	# Normalize so diagonal movement isn't faster
	direction = direction.normalized()
# Check for overlapping areas
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		if collision.get_collider() is Area2D:
			# Do something with the area
			var area = collision.get_collider()
			handle_area_collision(area)
	# Apply movement
	velocity = direction * speed
	move_and_slide()


			
func handle_area_collision(area):
	if area.is_in_group("special_area"):
		# Your custom logic here
		print("Collided with special area")
