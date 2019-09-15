extends TileMap

signal is_colliding_with_wall

func _on_Player_collided(collision, position):
	if collision.collider is TileMap:
		var tile_pos = world_to_map(position)
		tile_pos -= collision.normal
		var tile = get_cellv(tile_pos)
		
		if tile == 0:
			emit_signal("is_colliding_with_wall")