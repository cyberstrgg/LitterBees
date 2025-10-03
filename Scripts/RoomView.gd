# RoomView.gd
extends Control

# Update this line to point to the new HexagonContainer
@onready var hexagon_container: Control = $HexagonContainer
var is_panning: bool = false

func _gui_input(event: InputEvent):
    if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
        is_panning = event.is_pressed()
    
    if event is InputEventMouseMotion and is_panning:
        # Update this line to move the new container
        hexagon_container.position += event.relative
