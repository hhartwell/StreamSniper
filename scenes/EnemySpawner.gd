extends Node2D

# needed to know valid spawn locations
export(NodePath) var MapGenerator

# lets us spawn close to player
export(NodePath) var Player

onready var BasicEnemy = preload("res://scenes/BasicEnemy.tscn")


const SPAWN_OUTER_BOUND = 800
const SPAWN_INNER_BOUND = 200

# dict of nodepaths to enemies
# keys are ids
var enemy_dict = {}

var total_spawned = 0
var death_count = 0

func _ready():
	for i in range(100):
		spawn_enemy()
	pass # Replace with function body.

func _process(delta):
	if death_count - total_spawned == 0:
		spawn_enemy()

func spawn_enemy(display_name=null):
	
	# add mob to scene
	var mob = BasicEnemy.instance()
	
	mob.id = total_spawned
	mob.display_name = display_name
	mob.TARGET = '../' + Player

	total_spawned += 1
	enemy_dict[mob.id] = mob.get_path()
	
	# set spawn location using random distance and random angle
	var rng = RandomNumberGenerator.new()
	rng.seed = mob.id
	print(rng.randi_range(SPAWN_INNER_BOUND, SPAWN_OUTER_BOUND))
	var offset = rng.randi_range(SPAWN_INNER_BOUND, SPAWN_OUTER_BOUND)
	var rot = rng.randf_range(0, 2 * PI)
	var player = get_node(Player)
	var spawn_location = Vector2((offset + player.global_position.x) * cos(rot), (offset + player.global_position.y) * sin(rot))
	mob.global_position = Vector2(rng.randi_range(SPAWN_INNER_BOUND, SPAWN_OUTER_BOUND), rng.randi_range(SPAWN_INNER_BOUND, SPAWN_OUTER_BOUND))
	print(spawn_location)
	
	add_child(mob)
	

func despawn_enemy(id):
	var enemy_node = get_node_or_null(enemy_dict.get(id))
	print(enemy_node)
	death_count += 1
#	if enemy_node:
#		remove_child(enemy_node)
#		enemy_dict.erase(id)
		
	
