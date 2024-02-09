extends Sprite2D

@onready var upper_left: Marker2D = %UpperLeft
@onready var lower_right: Marker2D = %LowerRight

var speed = 400
var angular_speed = PI

func _process(delta):
	var direction = 0
	if Input.is_action_pressed("ui_left"): direction = -1
	if Input.is_action_pressed("ui_right"): direction = 1
	rotation += angular_speed * direction * delta

	var velocity = Vector2.ZERO
	if Input.is_action_pressed("ui_up"): velocity = Vector2.UP.rotated(rotation) * speed
	if Input.is_action_pressed("ui_down"): velocity = Vector2.DOWN.rotated(rotation) * speed
	
	position += velocity * delta
	if position.x > lower_right.position.x: position.x = upper_left.position.x
	elif position.x < upper_left.position.x: position.x = lower_right.position.x
	elif position.y > lower_right.position.y: position.y = upper_left.position.y
	elif position.y < upper_left.position.y: position.y = lower_right.position.y
