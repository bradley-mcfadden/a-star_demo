extends ColorRect
var mouse_within:bool = false

func _input(event):
	if Input.is_mouse_button_pressed(BUTTON_LEFT) && event is InputEventMouseMotion && mouse_within == true:
		rect_global_position += event.relative
	if Input.is_action_just_released("ui_lmbd"):
		rect_global_position = roundv(rect_global_position / 32) * 32

func _on_ColorRect_mouse_entered():
	mouse_within = true


func _on_ColorRect_mouse_exited():
	mouse_within = false

func roundv(vector:Vector2) -> Vector2:
	return Vector2(round(vector.x), round(vector.y))
