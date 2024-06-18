extends CharacterBody2D

@onready var world: TileMap = %World

var direction: Vector2 = Vector2()
var target_pos: Vector2 = Vector2()
var target_direction: Vector2 = Vector2()

var is_moving: bool = false
var speed: int = 0
var MAX_SPEED: int = 200

var astar_grid: AStarGrid2D
var curr_path: Array[Vector2i]

func _ready():
	self.position = Vector2(40, 40)
	astar_grid = AStarGrid2D.new()
	astar_grid.region = world.get_used_rect()
	astar_grid.cell_size = Vector2(16, 16)
	astar_grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	astar_grid.update()

func _process(delta):
	direction = Vector2()
	speed = 0
	
	for x in world.get_used_rect().size.x:
		for y in world.get_used_rect().size.y:
			var tile_position = Vector2i(
				x + world.get_used_rect().position.x,
				y + world.get_used_rect().position.y
			)
			var tile_data = world.get_cell_tile_data(0, tile_position)
			if tile_data == null or world.get_cell_tile_data(2, tile_position, Global.on_ground.has(tile_position)):
				astar_grid.set_point_solid(tile_position)
	
	if Input.is_action_pressed("temp_move"):
		var path = astar_grid.get_id_path(
			world.local_to_map(global_position),
			world.local_to_map(get_global_mouse_position())
		).slice(1)
		if path.is_empty() == false: curr_path = path
		var a_target = world.map_to_local(curr_path.front())
		global_position = global_position.move_toward(a_target, 3)
		
		if global_position == a_target: curr_path.pop_front()
		
		
	if Input.is_action_pressed("Right"): direction.x = 1
	elif Input.is_action_pressed("Left"): direction.x =-1
	elif Input.is_action_pressed("Down"): direction.y = 1
	elif Input.is_action_pressed("Up"): direction.y = -1
	
	if not is_moving and direction != Vector2(): 
		target_direction = direction.normalized()
		if not world.is_on_ground(position, target_direction) and not world.is_enterance(position, target_direction):
			target_pos = position + target_direction * 16
			is_moving = true
		if (get_tree().current_scene.name == "Main"):
			Global.current = "res://node_2d.tscn"
			Global.change = "res://Ocean.tscn"
		elif (get_tree().current_scene.name == "Ocean"):
			Global.change = "res://node_2d.tscn"
			Global.current = "res://Ocean.tscn"
		if world.is_enterance(position, target_direction):
			get_tree().change_scene_to_file("res://loading.tscn")
		if self.position == $"../npc".position - Vector2(16, 0) || self.position == $"../npc".position + Vector2(16, 0) || self.position == $"../npc".position - Vector2(0, 16) || self.position == $"../npc".position + Vector2(0, 16):
			print("combat")
			Global.change = "res://combat.tscn"
			get_tree().change_scene_to_file("res://loading.tscn")
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
