extends KinematicBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export(int) var MAX_MOVE_SPEED = 400
export(int) var BULLET_SPEED = 1000
export(Resource) var bullet_kit

var MAX_HEALTH = 100


const FIRERATE = 0.3

var fire_timer = 0

var current_health = MAX_HEALTH

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func _process(delta):
	current_health -= delta
	print(current_health/ MAX_HEALTH)

	var move_dir = _get_movement_dir()
	var movement = _process_movemnt(move_dir)
	$healthbar.material.set_shader_param('health', current_health/ MAX_HEALTH)
	move_and_slide(movement)
	_process_shoot(delta)

func _process_shoot(delta):
	var mouse_pos = get_global_mouse_position()
	var end = mouse_pos
	var start = global_position
	var vec = (end - start).normalized() * BULLET_SPEED
	var properties = {
		"transform": Transform2D(vec.angle(), global_position),
		"velocity": vec
	}
#	if Input.is_action_just_pressed("shoot"):
	if Input.is_action_pressed("shoot"):
		if fire_timer > FIRERATE:
			Bullets.spawn_bullet(bullet_kit, properties)
			fire_timer = 0
	fire_timer += delta
		
func _get_movement_dir():
	if Input.is_action_pressed("move_up"):
		if Input.is_action_pressed("move_right"):
			return 2
		elif Input.is_action_pressed("move_left"):
			return 8
		else:
			return 1
	elif Input.is_action_pressed("move_down"):
		if Input.is_action_pressed("move_right"):
			return 4
		elif Input.is_action_pressed("move_left"):
			return 6
		else:
			return 5
	
	elif Input.is_action_pressed("move_right"):
		return 3
	
	elif Input.is_action_pressed("move_left"):	
		return 7
func _process_movemnt(dir):
	var movement = Vector2.ZERO
	match(dir):
		1:
			# up
			movement.y = -MAX_MOVE_SPEED
		2:
			# up right
			movement.x = MAX_MOVE_SPEED
			movement.y = -MAX_MOVE_SPEED
		3:
			# right
			movement.x = MAX_MOVE_SPEED	
		4:
			# down right
			movement.x = MAX_MOVE_SPEED
			movement.y = MAX_MOVE_SPEED
		5:
			# down
			movement.y = MAX_MOVE_SPEED
		6:
			# down left
			movement.x = -MAX_MOVE_SPEED
			movement.y = MAX_MOVE_SPEED
		7:
			# left 
			movement.x = -MAX_MOVE_SPEED
		8:
			# up left
			movement.x = -MAX_MOVE_SPEED
			movement.y = -MAX_MOVE_SPEED
	return movement
