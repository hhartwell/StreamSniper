extends Node2D
#
#onready var dirt_tilemap = $DirtTileMap
#onready var wall_tilemap = $WallTileMap
onready var grass_tilemap = $GrassTileMap

var rng = RandomNumberGenerator.new()

var CellSize = Vector2(16, 16)
var width = 1024/CellSize.x * 5
var height = 1024/CellSize.y * 5
var grid = []

#var Tiles = {
#    "empty": -1,
#    "wall": 0,
#    "floor": 1
#}
var Tiles = {
	"grass_0": 0,
	"grass_1": 1,
	"grass_2": 2,
	"grass_3": 3
}

func _init_grid():
	print('w', width)
	print('h', height)
	grid = []
	for x in width:
		grid.append([])
		for y in height:
			grid[x].append(0);


func GetRandomDirection():
	var directions = [[-1, 0], [1, 0], [0, 1], [0, -1]]
	var direction = directions[rng.randi()%4]
	return Vector2(direction[0], direction[1])
	
func _create_random_path():
	var max_iterations = 5000
	var itr = 0
	
	var walker = Vector2.ZERO
	
	while itr < max_iterations:
		
		# Perform random walk
		# 1- choose random direction
		# 2- check that direction is in bounds
		# 3- move in that direction
		var random_direction = GetRandomDirection()
		
		if (walker.x + random_direction.x >= 0 and 
			walker.x + random_direction.x < width and
			walker.y + random_direction.y >= 0 and
			walker.y + random_direction.y < height):
				
				walker += random_direction
				var choices = [0, 1, 2, 3]
				var tile = choices[rng.randi()%3]
				match(tile):
					0:
						grid[walker.x][walker.y] = Tiles.grass_1
					1:
						grid[walker.x][walker.y] = Tiles.grass_2
					2:
						grid[walker.x][walker.y] = Tiles.grass_3
#				grid[walker.x][walker.y] = Tiles.grass_1
				itr += 1
	
func _spawn_tiles():
	for x in width:
		for y in height:
			match grid[x][y]:
				Tiles.grass_0:
					grass_tilemap.set_cellv(Vector2(x, y), 0)
				Tiles.grass_1:
					grass_tilemap.set_cellv(Vector2(x, y), 1)
				Tiles.grass_2:
					grass_tilemap.set_cellv(Vector2(x, y), 2)
				Tiles.grass_3:
					grass_tilemap.set_cellv(Vector2(x, y), 3)


func _clear_tilemaps():
	for x in width:
		for y in height:
			grass_tilemap.clear()
  
	grass_tilemap.update_bitmask_region()

func _ready():
	rng.randomize()
	_init_grid()
	_clear_tilemaps()
	_create_random_path()
	_spawn_tiles()

