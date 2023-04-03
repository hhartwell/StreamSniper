extends KinematicBody2D

onready var deathshader = preload("res://shaders/death_animation.tres")

export(Resource) var bullet_kit

export var SPAWNER: NodePath

export(int) var MAX_MOVE_SPEED = 300
export(int) var BULLET_SPEED = 1000
export(int) var NEW_DIRECTION_INTERVAL = 1

export(int) var DANGER_ZONE = 700
export(int) var DANGER_BUFFER = 300
export var TARGET: NodePath
const MAX_HEALTH = 100
const FIRERATE = 1

var display_name
var id

var current_health = float(MAX_HEALTH)

var direction = 1
var direction_timer = 0

var BULLET_DMG_COOLDOWN = 0.1
var dmg_cooldown_timer = 0

var fire_timer = 0

var dying = false

const TIME_TO_DIE = 1
var death_animation_timer = TIME_TO_DIE

func _ready():
	pass
	
func _process(delta):
	
	if dying:
		$CollisionShape2D/Sprite.material.set_shader_param('opacity', death_animation_timer/TIME_TO_DIE)
		death_animation_timer -= delta
		if death_animation_timer <= 0:
			get_parent().despawn_enemy(id)
			get_parent().remove_child(self)
		return

	$health.material.set_shader_param('health', current_health/ MAX_HEALTH)
	
	var target_pos = get_node(TARGET).global_position
	var target_dist = target_pos.distance_to(global_position)
	var movement = Vector2.ZERO
	dmg_cooldown_timer += delta
	
	if target_dist <= DANGER_ZONE and target_dist >= DANGER_BUFFER:
		_process_shoot(delta)
		var distance_vec = (target_pos - global_position).normalized()
		if distance_vec.x > 0 and distance_vec.y > 0:
			direction = 5
			
		if distance_vec.x > 0 and distance_vec.y < 0:
			direction = 3
			
		if distance_vec.x < 0 and distance_vec.y < 0:
			direction = 1
			
		if distance_vec.x < 0 and distance_vec.y > 0:
			direction = 7
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
	elif interval >= theta and theta < interval * 2:
		# down right
		return 4
	elif interval * 2 >= theta and theta < interval * 3:
		# down
		return 5
	elif interval * 3 >= theta and theta < interval * 4:
		return 6
		# down left
	elif interval * 4 >= theta and theta < interval * 5:
		return 7
		# left
	elif interval * 5 >= theta and theta < interval * 6:
		return 8
		# up left 
	elif interval * 6 >= theta and theta < interval * 7:
		return 1
		# up
	else:
		return 2
		# up right
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

func _process_shoot(delta):
	if fire_timer > FIRERATE:
		var end = get_node(TARGET).global_position
		var start = global_position
		var vec = (end - start).normalized() * BULLET_SPEED
		var properties = {
			"transform": Transform2D(vec.angle(), global_position),
			"velocity": vec,
			"data": {'is_enemy': true}
		}
		Bullets.spawn_bullet(bullet_kit, properties)
		fire_timer = 0
	fire_timer += delta

func _on_BulletArea_area_shape_entered(area_rid, area, area_shape_index, local_shape_index):
	if not Bullets.is_bullet_existing(area_rid, area_shape_index):
		# The colliding area is not a bullet, returning.
		return
	var bullet_id = Bullets.get_bullet_from_shape(area_rid, area_shape_index)
	var bullet_transform = Bullets.get_bullet_property(bullet_id, "transform")
	
	var bullet_is_enemy = Bullets.get_bullet_property(bullet_id, "data").is_enemy
	if dmg_cooldown_timer > BULLET_DMG_COOLDOWN and !bullet_is_enemy:
		Bullets.call_deferred("release_bullet", bullet_id)
		take_damage(20)
			
func take_damage(damage: float):
	current_health -= damage
	dmg_cooldown_timer = 0
	if current_health <= 0:
		death()

func death():
	dying = true
	$CollisionShape2D.disabled=true
	$BulletArea/BulletCollider.disabled = true
	$health.visible = false
	$CollisionShape2D/Sprite.material = deathshader
