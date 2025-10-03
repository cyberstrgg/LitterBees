# HexButton.gd
class_name HexButton
extends Control

signal pressed

# --- Node References ---
@onready var polygon_2d: Polygon2D = $Polygon2D
@onready var label: Label = $Label

# --- Properties ---
@export var text: String = "Button":
    set(value):
        text = value
        if is_instance_valid(label):
            label.text = text

@export var disabled: bool = false:
    set(value):
        disabled = value
        update_visuals()

# --- Colors for different states ---
@export_group("Appearance")
@export var color_normal := Color(0.3, 0.3, 0.35)
@export var color_hover := Color(0.45, 0.45, 0.5)
@export var color_pressed := Color(0.2, 0.2, 0.25)
@export var color_disabled := Color(0.15, 0.15, 0.18, 0.5)

# --- Internal State ---
var _is_hovered := false
var _is_pressed_inside := false

func _ready():
    # Ensure the label text is set on load
    label.text = text
    
    # Resize the label to fill the control's area
    label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    
    # We must wait a frame for the control's size to be determined by the layout
    await get_tree().process_frame
    draw_hexagon()
    update_visuals()
    
    # Connect signals to track mouse state
    mouse_entered.connect(func(): _is_hovered = true; update_visuals())
    mouse_exited.connect(func(): _is_hovered = false; _is_pressed_inside = false; update_visuals())

func draw_hexagon():
    var hex_points = PackedVector2Array()
    var center = size / 2.0
    for i in range(6):
        var angle_rad = deg_to_rad(60 * i + 30) # Pointy-top
        hex_points.append(center + Vector2(size.x / 2.0 * cos(angle_rad), size.y / 2.0 * sin(angle_rad)))
    polygon_2d.polygon = hex_points

func _gui_input(event: InputEvent):
    if disabled:
        return

    if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
        var is_inside = Geometry2D.is_point_in_polygon(event.position, polygon_2d.polygon)
        
        if event.is_pressed() and is_inside:
            _is_pressed_inside = true
            update_visuals()
            get_viewport().set_input_as_handled()
            
        elif event.is_released() and _is_pressed_inside:
            # Check if the mouse is still inside when released
            if is_inside:
                emit_signal("pressed")
            
            _is_pressed_inside = false
            update_visuals()
            get_viewport().set_input_as_handled()

func update_visuals():
    if disabled:
        polygon_2d.color = color_disabled
    elif _is_pressed_inside:
        polygon_2d.color = color_pressed
    elif _is_hovered:
        polygon_2d.color = color_hover
    else:
        polygon_2d.color = color_normal
