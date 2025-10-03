extends Control

@onready var grid_container: Node2D = $GridContainer # Changed from GridContainer
var is_panning: bool = false

# This function is automatically called when a mouse event happens inside this control.
func _gui_input(event: InputEvent):
    if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
        is_panning = event.is_pressed()
    
    if event is InputEventMouseMotion and is_panning:
        grid_container.position += event.relative
