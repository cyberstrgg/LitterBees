# Scripts/RoomView.gd
extends Control

@onready var grid_container: Node2D = $GridContainer
var is_panning: bool = false

func _process(_delta):
	# Request a redraw every frame so outlines are updated when panning.
	queue_redraw()

func _draw():
	if not is_instance_valid(grid_container):
		return

	# Loop through all the hexagon nodes in the grid
	for child in grid_container.get_children():
		# Find the Polygon2D child by iterating and checking its type.
		var poly_node = null
		for subchild in child.get_children():
			if subchild is Polygon2D:
				poly_node = subchild
				break # Found it, stop searching

		if poly_node and not poly_node.polygon.is_empty():
			# THE FIX: Manually build the transform from the Control node's properties.
			var child_local_transform = Transform2D(child.rotation, child.position).scaled(child.scale)
			var final_transform = grid_container.transform * child_local_transform
			
			draw_set_transform_matrix(final_transform)
			draw_polyline(poly_node.polygon, Color.BLACK, 2.0)

	# Reset the transform at the end to not affect other UI elements.
	draw_set_transform_matrix(Transform2D())

func _gui_input(event: InputEvent):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		is_panning = event.is_pressed()
	
	if event is InputEventMouseMotion and is_panning:
		grid_container.position += event.relative
