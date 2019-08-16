extends KinematicBody2D

export var color:Color = Color(255, 255, 255)
const GRAVITY = 1000
const MAX_FALL_SPEED = 900
const WALK_SPEED = 160
const JUMP_SPEED = 410
onready var velocity:Vector2 = Vector2(0, 0)
onready var is_jumping:bool = false
onready var direction:int = 1


func _ready():
	$Polygon2D.color = color


func _physics_process(delta:float):
	velocity.x = 0
	velocity.y += delta * GRAVITY
	velocity.y = min(MAX_FALL_SPEED, velocity.y)
	velocity = move_and_slide(velocity, Vector2(0, -1))


func jump():
	if is_on_floor() == true && is_jumping == false:
		velocity.y -= JUMP_SPEED
		is_jumping == true


func move_left():
	velocity.x = -WALK_SPEED


func move_right():
	velocity.x = WALK_SPEED