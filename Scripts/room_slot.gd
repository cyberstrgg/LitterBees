# Scripts/room_slot.gd
extends PanelContainer

signal build_room_requested(room_type, cost, axial_coordinates)

const DamageRoom = preload("res://Scripts/UpgradeRooms/bees/damage_room.gd")
const SpeedRoom = preload("res://Scripts/UpgradeRooms/bees/speed_room.gd")
const RecoveryRoom = preload("res://Scripts/UpgradeRooms/bees/recovery_room.gd")

@onready var build_menu = $BuildMenu
@onready var build_label = $BuildLabel
@onready var build_damage_button = $BuildMenu/CenterContainer/VBoxContainer/BuildDamageButton
@onready var build_speed_button = $BuildMenu/CenterContainer/VBoxContainer/BuildSpeedButton
@onready var build_recovery_button = $BuildMenu/CenterContainer/VBoxContainer/BuildRecoveryButton
@onready var polygon_2d = $Polygon2D
@onready var background_hex: Polygon2D = $BuildMenu/BackgroundHex

var damage_cost: int
var speed_cost: int
var recovery_cost: int

var axial_coordinates: Vector2i

func _ready():
	var size = self.custom_minimum_size
	var center = size / 2.0
	var hexagon_points = PackedVector2Array()
	for i in range(6):
		var angle_deg = 60 * i + 30
		var angle_rad = deg_to_rad(angle_deg)
		hexagon_points.append(center + Vector2(center.x * cos(angle_rad), center.y * sin(angle_rad)))
	
	polygon_2d.polygon = hexagon_points
	polygon_2d.color = Color(0.2, 0.2, 0.2, 0.8)

	background_hex.polygon = hexagon_points

	build_damage_button.pressed.connect(_on_build_room_type_pressed.bind("damage"))
	build_speed_button.pressed.connect(_on_build_room_type_pressed.bind("speed"))
	build_recovery_button.pressed.connect(_on_build_room_type_pressed.bind("recovery"))
	
	damage_cost = DamageRoom.new().base_cost
	speed_cost = SpeedRoom.new().base_cost
	recovery_cost = RecoveryRoom.new().base_cost
	
	update_button_text()

func update_button_text():
	build_damage_button.text = "Barracks (%d)" % damage_cost
	build_speed_button.text = "Apiary (%d)" % speed_cost
	build_recovery_button.text = "Nursery (%d)" % recovery_cost

func _on_build_button_pressed():
	build_menu.visible = true
	build_label.visible = false

func _on_build_room_type_pressed(type: String):
	match type:
		"damage":
			emit_signal("build_room_requested", "damage", damage_cost, axial_coordinates)
		"speed":
			emit_signal("build_room_requested", "speed", speed_cost, axial_coordinates)
		"recovery":
			emit_signal("build_room_requested", "recovery", recovery_cost, axial_coordinates)

func _has_point(point: Vector2) -> bool:
	return Geometry2D.is_point_in_polygon(point, polygon_2d.polygon)

func _gui_input(event: InputEvent):
	if event is InputEventMouseButton and event.is_pressed():
		if event.button_index == MOUSE_BUTTON_LEFT:
			if not build_menu.visible:
				_on_build_button_pressed()
		
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			if build_menu.visible:
				build_menu.visible = false
				build_label.visible = true
