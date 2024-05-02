extends TileMap

# Called when the node enters the scene tree for the first time.
func _ready():
	if (Global.main):
		Global.main = false
		await get_tree().create_timer(3.0).timeout
		get_tree().change_scene_to_file("res://Ocean.tscn")
	elif (Global.ocean):
		Global.ocean = false
		await get_tree().create_timer(3.0).timeout
		get_tree().change_scene_to_file("res://node_2d.tscn")
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
