extends TileMap

func _unhandled_input(event):
	if event is InputEventMouseButton && event.pressed == true:
		print(event.as_text())
		if event.button_index == BUTTON_LEFT:
			set_cellv(world_to_map(event.position), 0)
		elif event.button_index == BUTTON_RIGHT:
			set_cellv(world_to_map(event.position), 1)