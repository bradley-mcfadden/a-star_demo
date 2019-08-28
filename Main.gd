extends Node

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
#warning-ignore:unused_argument
func _process(delta:float):
	# print($TileMap.get_cellv(Vector2(0, 0)))
	if Input.is_action_pressed("jump"):
		$TileMap/Player.jump()
	if Input.is_action_pressed("move_left"):
		$TileMap/Player.move_left()
	if Input.is_action_pressed("move_right"):
		$TileMap/Player.move_right()
