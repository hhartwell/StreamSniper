extends KinematicBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export(int) var MAX_MOVE_SPEED = 400
export(int) var BULLET_SPEED = 1000
export(Resource) var bullet_kit

var MAX_HEALTH = 100

const BULLET_DMG_COOLDOWN = .2
var dmg_cooldown_timer = 0

const FIRERATE = 0.3

var fire_timer = 0

var current_health = float(MAX_HEALTH)

var laser_screech_sound = preload("res://sounds/ScreechWithEnd.wav")
#var laser_start_sound = preload("res://sounds/LongScreech.wav")
#var laser_end_sound = preload("res://sounds/ScreechEnd.wav")
var laser_charge = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func _process(delta):
	dmg_cooldown_timer += delta
	$healthbar.material.set_shader_param('health', current_health / MAX_HEALTH)
	var move_dir = _get_movement_dir()
	var movement = _process_movemnt(move_dir)
	move_and_slide(movement)
	_process_shoot(delta)

func _process_shoot(delta):
	var mouse_pos = get_global_mouse_position()
	var end = mouse_pos
	var start = global_position
	var vec = (end - start).normalized() * BULLET_SPEED
	var properties = {
		"transform": Transform2D(vec.angle(), global_position),
		"velocity": vec,
		"data": {'is_enemy': false}
	}
	
	
	if Input.is_action_pressed("special") and fire_timer > FIRERATE:
		if not $Laser.is_casting:
			$Laser.is_casting = true
		
		# if we just started charging laser play charge up noise
		if laser_charge == 0:
			$"../AudioStreamPlayer".stream = laser_screech_sound
			$"../AudioStreamPlayer".play()
		
		laser_charge += .01  # make this take ~1.5 seconds?
		
		# if laser charge is full, it does more power or whatever
		
		print("CHARGING " + str(laser_charge))
			
		if laser_charge > 10:
			print("%%%%%%%%%%%% SPECIAL!")
			
			#$"../AudioStreamPlayer".stream = laser_end_sound
			#$"../AudioStreamPlayer".play()
			
			$Laser.is_casting = false
			
			#laser_charge = 0
			fire_timer = -100
			
	elif laser_charge > 0 and fire_timer > 0:
		# Laser was charging, but isn't any more .. reset it and stop noise!
		$Laser.is_casting = false
		laser_charge = 0
		$"../AudioStreamPlayer".stop()
	
#	if Input.is_action_just_pressed("shoot"):
	elif Input.is_action_pressed("shoot"):
		if fire_timer > FIRERATE:
			Bullets.spawn_bullet(bullet_kit, properties)
			
#			var bullet_id = Bullets.obtain_bullet(bullet_kit)
			
			
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


func _on_Area2D_area_shape_entered(area_rid, area, area_shape_index, local_shape_index):
	
	if not Bullets.is_bullet_existing(area_rid, area_shape_index):
		# The colliding area is not a bullet, returning.
		return
	var bullet_id = Bullets.get_bullet_from_shape(area_rid, area_shape_index)
	var bullet_transform = Bullets.get_bullet_property(bullet_id, "transform")
	
	var bullet_is_enemy = Bullets.get_bullet_property(bullet_id, "data").is_enemy
	if dmg_cooldown_timer > BULLET_DMG_COOLDOWN and bullet_is_enemy:
		Bullets.call_deferred("release_bullet", bullet_id)
		print(current_health)
		current_health -= 20
		dmg_cooldown_timer = 0
		print(current_health)
		
