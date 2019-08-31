extends TileMap


func _ready():
	$CPUController.goal = world_to_map($Goal.rect_global_position)
	$CPUController.start = world_to_map($Start.rect_global_position)


func _input(event):
	if Input.is_action_just_released("ui_lmbd"):
		update_path()


func update_path():
	$CPUController.goal = world_to_map($Goal.rect_global_position)
	$CPUController.start = world_to_map($Start.rect_global_position)
	$CPUController.find_path()


func _unhandled_input(event):
	if event is InputEventMouseButton && event.pressed == true:
		if event.button_index == BUTTON_LEFT:
			set_cellv(world_to_map(event.position), 0)
		elif event.button_index == BUTTON_RIGHT:
			set_cellv(world_to_map(event.position), 1)
		update_path()