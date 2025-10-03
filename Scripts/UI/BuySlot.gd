# Scripts/UI/BuySlot.gd
extends PanelContainer

signal pressed

@onready var polygon_2d: Polygon2D = $Polygon2D
@onready var label: Label = $Label

var disabled: bool = false

func _ready():
	var size = self.custom_minimum_size
	var center = size / 2.0
	var hex_points = PackedVector2Array()
	for i in range(6):
		var angle_rad = deg_to_rad(60 * i + 30) # Pointy-top
		hex_points.append(center + Vector2(size.x / 2.0 * cos(angle_rad), size.y / 2.0 * sin(angle_rad)))
	
	polygon_2d.polygon = hex_points
	polygon_2d.color = Color(0.1, 0.1, 0.1, 0.7)
	
	label.text = "Buy Slot\n(%d Scrap)" % GlobalUpgrades.NEW_SLOT_COST
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER

# This function defines the hexagonal clickable area
func _has_point(point: Vector2) -> bool:
	if disabled:
		return false
	return Geometry2D.is_point_in_polygon(point, polygon_2d.polygon)

# This function handles the click
func _gui_input(event: InputEvent):
	if disabled:
		return
	if event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
		if _has_point(event.position):
			emit_signal("pressed")

# This allows the main menu to enable/disable the button
func update_state(scrap_available: int):
	disabled = scrap_available < GlobalUpgrades.NEW_SLOT_COST
	if disabled:
		modulate = Color(0.5, 0.5, 0.5) # Grayed out when disabled
	else:
		modulate = Color.WHITE
