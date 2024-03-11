extends CharacterBody2D

@onready var world: TileMap = %World

var direction: Vector2 = Vector2()
var target_pos: Vector2 = Vector2()
var target_direction: Vector2 = Vector2()

var is_moving: bool = false
var speed: int = 0
var MAX_SPEED: int = 200
var astar_grid: AStarGrid2D

func _ready():
	self.position = Vector2(40, 40)

func _process(delta):
	direction = Vector2()
	speed = 0
	
	if Input.is_action_pressed("Right"): direction.x = 1
	elif Input.is_action_pressed("Left"): direction.x =-1
	elif Input.is_action_pressed("Down"): direction.y = 1
	elif Input.is_action_pressed("Up"): direction.y = -1
	
	if not is_moving and direction != Vector2(): 
		target_direction = direction.normalized()
		if not world.is_on_ground(position, target_direction):
			target_pos = position + target_direction * 16
			is_moving = true
	elif is_moving:
		speed = MAX_SPEED
		velocity = speed * target_direction * delta
		
		var distance_to_target = position.distance_to(target_pos)
		var move_distance = velocity.length()
		if move_distance > distance_to_target:
			velocity = distance_to_target * target_direction
			is_moving = false
		
		move_and_collide(velocity)

func _on_area_2d_body_entered(body):
	print("collided")
