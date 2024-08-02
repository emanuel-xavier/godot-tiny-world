extends Node2D

const FOAM: PackedScene = preload("res://management/foam.tscn")
const DEFAUL_LAYER: int = 0

@onready var grass_tilemap: TileMap = get_node("Grass")
@onready var water_tilemap: TileMap = get_node("Water")

var grass_used_cells: Array
var water_used_cells: Array

func _ready() -> void:
	var used_grass_rect: Rect2 = grass_tilemap.get_used_rect()
	grass_used_cells = grass_tilemap.get_used_cells(0)
	generate_watter_tiles(used_grass_rect)
	
	water_used_cells = water_tilemap.get_used_cells(DEFAUL_LAYER)
	generate_foam_tiles()
	
func generate_watter_tiles(used_grass_rect: Rect2) -> void:
	for x in range(used_grass_rect.position.x -20, used_grass_rect.size.x + 20):
		for y in range(used_grass_rect.position.y -20, used_grass_rect.size.y + 20):
			if grass_used_cells.has(Vector2i(x, y)):
				continue
			water_tilemap.set_cell(DEFAUL_LAYER, Vector2i(x, y), DEFAUL_LAYER, Vector2i(0, 0))


func generate_foam_tiles() -> void:
		for cell in grass_used_cells:
			if check_grass_neighbors(cell):
				spawn_foam(cell)
			
			
func check_grass_neighbors(cell) -> bool:
	var left_neighbor: Vector2i = Vector2i(cell.x - 1, cell.y)
	var right_neighbor: Vector2i = Vector2i(cell.x + 1, cell.y)
	var top_neighbor: Vector2i = Vector2i(cell.x, cell.y - 1)
	var bottom_neighbor: Vector2i = Vector2i(cell.x, cell.y + 1)
	
	var neighbor_list = [
		left_neighbor,
		right_neighbor,
		top_neighbor,
		bottom_neighbor,
	]
	
	for neighbor in neighbor_list:
		if water_used_cells.has(neighbor):
			return true
			
	return false


func spawn_foam(foam_cell: Vector2) -> void:
	var foam = FOAM.instantiate()
	add_child(foam)
	foam.position = foam_cell * 64.0 + Vector2(32, 32)
	
	
	
