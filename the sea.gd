extends TileMap

var INT_MIN: int = -9_223_372_036_854_775_808
var INT_MAX: int = 9_223_372_036_854_775_807

func _ready():
	Global.on_ground = get_layer_array(1)
	Global.enterance = get_layer_array(2)

func _process(delta):
	pass

func get_layer_array(layer: int):
	var output: Array = self.get_used_cells(layer)
	var other_cells: Array
	
	for cell: Vector2i in output:
		var points: PackedVector2Array = self.get_cell_tile_data(layer, cell).get_collision_polygon_points(0, 0)
		points.sort()
		print(points)
		
		var included_cells: Array = get_cell_inside_region(Array(points))
		for cell_included: Vector2i in included_cells:
			if cell_included != Vector2i(0, 0): 
				other_cells.append(cell + cell_included)
	
	output.append_array(other_cells)
	return output

func get_cell_inside_region(region_points: Array):
	var included_cells: Array = []
	
	var x_min: int = INT_MAX
	var y_min: int = INT_MAX
	var x_max: int = INT_MIN
	var y_max: int = INT_MIN
	
	for point: Vector2 in region_points:
		x_min = min(x_min, point.x)
		y_min = min(y_min, point.y)
		x_max = max(x_max, point.x)
		y_max = max(y_max, point.y)
	
	for i in range(x_min / 16, (x_max / 16) + 1):
		for j in range(y_min / 16, (y_max / 16) + 1):
			var cell: Vector2i = Vector2i(i, j)
			if is_inside_region(cell, region_points): included_cells.append(cell)
	
	return included_cells

func is_inside_region(cell: Vector2i, region_points: Array):
	for i in 4:
		var p1: Vector2 = region_points[i]
		var p2: Vector2 = region_points[(i + 1) % region_points.size()]
		var p3: Vector2 = region_points[(i + 2) % region_points.size()]
		
		if (cross_product(cell, p1, p2) <= 0 && 
			cross_product(cell, p2, p3) <= 0 && 
			cross_product(cell, p3, p1) <= 0):
			return true
	
	return false

func cross_product(p1: Vector2, p2: Vector2, p3: Vector2):
	return (p2.x - p1.x) * (p3.y - p1.y) - (p3.x - p1.x) * (p2.y - p1.y)

func is_on_ground(pos: Vector2, direction: Vector2):
	var target_pos = pos + direction * 16
	var target_cell = Vector2i((target_pos - Vector2(8, 8)) / 16)
	return target_cell in Global.on_ground

func is_enterance(pos: Vector2, direction: Vector2):
	var target_pos = pos + direction * 16
	var target_cell = Vector2i((target_pos - Vector2(8, 8)) / 16)
	return target_cell in Global.enterance
