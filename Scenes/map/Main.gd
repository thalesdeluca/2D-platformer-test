extends Node2D

signal is_colliding_with_wall

var tilemap

func _ready():
	tilemap = $TileMap

func _on_Player_collided(collision, position):
	if collision.collider is TileMap:
		var tile_pos = tilemap.world_to_map(position)
		tile_pos -= collision.normal
		var tile = tilemap.get_cellv(tile_pos)
		match tile:
			0:
				emit_signal("is_colliding_with_wall")