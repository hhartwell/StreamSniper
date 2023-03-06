extends KinematicBody2D
#const MAX_MOVE_SPEED = 500
export(int) var MAX_MOVE_SPEED = 500
export(int) var NEW_DIRECTION_INTERVAL = 1

export(int) var DANGER_ZONE = 300
export(int) var DANGER_BUFFER = 50
export var TARGET: NodePath

var direction = 1
var direction_timer = 0

func _process(delta):
	var target_pos = get_node(TARGET).global_position
	var target_dist = target_pos.distance_to(global_position)
	var movement = Vector2.ZERO
	if target_dist <= DANGER_ZONE and target_dist >= DANGER_BUFFER:
		var distance_vec = (target_pos - global_position).normalized()
		if distance_vec.x > 0 and distance_vec.y > 0:
			direction = 5
			
		if distance_vec.x > 0 and distance_vec.y < 0:
			direction = 3
			
		if distance_vec.x < 0 and distance_vec.y < 0:
			direction = 1
			
		if distance_vec.x < 0 and distance_vec.y > 0:
			direction = 7
			
#		print(distance_vec.normalized())
		direction_timer = 0

		move_and_slide(distance_vec * MAX_MOVE_SPEED)
		
	else:
		if direction_timer > NEW_DIRECTION_INTERVAL:
			direction_timer = 0
			direction = randi()%8+1
		else:
			direction_timer += delta
		movement = _process_movemnt(direction)
	move_and_slide(movement)

func _process_vec_dir(dir: Vector2):
	
	var interval = PI / 4.0
	var interval_offset = interval / 2.0
	
	var theta = dir.angle() + interval_offset
	
	if 0 >= theta and theta < interval:
		return 3
		pass
	elif interval >= theta and theta < interval * 2:
		return 4
		# down right
		pass
	elif interval * 2 >= theta and theta < interval * 3:
		return 5
		# down
		pass
	elif interval * 3 >= theta and theta < interval * 4:
		return 6
		# down left
		pass
	elif interval * 4 >= theta and theta < interval * 5:
		return 7
		# left
		pass
	elif interval * 5 >= theta and theta < interval * 6:
		return 8
		# up left 
		pass
	elif interval * 6 >= theta and theta < interval * 7:
		return 1
		# up
		pass
	else:
		return 2
		# up right
		pass
	print(dir)
	pass
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
