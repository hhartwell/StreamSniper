extends Node2D

# needed to know valid spawn locations
export(NodePath) var MapGenerator

# lets us spawn close to player
export(NodePath) var Player

onready var BasicEnemy = preload("res://scenes/BasicEnemy.tscn")
onready var kit = preload("res://kits/green_basic_bullet_kit.tres")

const SPAWN_OUTER_BOUND = 700
const SPAWN_INNER_BOUND = 300

# dict of nodepaths to enemies
# keys are ids
var enemy_dict = {}

var total_spawned = 0
var death_count = 0

func _ready():
	if death_count == total_spawned:
		print('here')
		spawn_enemy()
	pass # Replace with function body.

func spawn_enemy(display_name=null):
	
	# add mob to scene
	var mob = BasicEnemy.instance()
	print(get_parent())
	get_parent().add_child(mob)
	mob.id = total_spawned
	mob.display_name = display_name
	mob.TARGET = Player
	mob.bullet_kit = kit
	total_spawned += 1
	enemy_dict[mob.id] = mob.get_path()
	
	# set spawn location using random distance and random angle
	var rng = RandomNumberGenerator.new()
	var offset = rng.randi_range(SPAWN_INNER_BOUND, SPAWN_OUTER_BOUND)
	var rot = rng.randf_range(0, 2 * PI)
	var player = get_node(Player)
	print(player.global_position)
	var spawn_location = Vector2((offset + player.global_position.x) * cos(rot), (offset + player.global_position.y) * sin(rot))
	mob.global_position = Vector2(300, 300)
	print(spawn_location)
	

func despawn_enemy(id):
	var enemy_node = get_node_or_null(enemy_dict.get(id))
	if enemy_node:
		enemy_dict.erase(id)
		enemy_node.get_parent().remove_child(enemy_node)
		death_count += 1
	
