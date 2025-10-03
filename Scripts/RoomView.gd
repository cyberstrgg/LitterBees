# Scripts/RoomView.gd
extends Control

@onready var grid_container: Node2D = $GridContainer
var is_panning: bool = false

func _process(_delta):
	# Request a redraw every frame so outlines are updated when panning.
	queue_redraw()

func _draw():
	# This function will now draw all outlines on top of the hexagons.
	if not is_instance_valid(grid_container):
		return

	# Loop through all the hexagon nodes in the grid
	for child in grid_container.get_children():
		# Check if the child has a Polygon2D node
		var poly_node = child.get_node_or_null("Polygon2D")
		if poly_node and not poly_node.polygon.is_empty():
			# Temporarily move our "pen" to the child's position
			draw_set_transform(child.position, child.rotation, child.scale)
			# Draw the outline using the child's polygon data
			draw_polyline(poly_node.polygon, Color.BLACK, 2.0)
			# Reset the transform so the next outline draws in the correct place
			draw_set_transform(Vector2.ZERO, 0, Vector2.ONE)

func _gui_input(event: InputEvent):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		is_panning = event.is_pressed()
	
	if event is InputEventMouseMotion and is_panning:
		grid_container.position += event.relative
