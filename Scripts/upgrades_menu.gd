# upgrades_menu.gd
extends CanvasLayer

signal menu_closed

@onready var room_view: Control = $CenterContainer/PanelContainer/VBoxContainer/RoomView
@onready var grid: Node2D = $CenterContainer/PanelContainer/VBoxContainer/RoomView/GridContainer
@onready var back_button: Button = $CenterContainer/PanelContainer/VBoxContainer/BackButton
@onready var scrap_label: Label = $CenterContainer/PanelContainer/VBoxContainer/ScrapLabel

const ROOM_SLOT_SCENE = preload("res://Scenes/room_slot.tscn")
const THRONE_ROOM_SCENE = preload("res://Scenes/throne_room.tscn")
const UPGRADE_ROOM_SCENE = preload("res://Scenes/UpgradeRooms/upgrade_room.tscn")
const DamageRoom = preload("res://Scripts/UpgradeRooms/bees/damage_room.gd")
const SpeedRoom = preload("res://Scripts/UpgradeRooms/bees/speed_room.gd")
const RecoveryRoom = preload("res://Scripts/UpgradeRooms/bees/recovery_room.gd")
const HEX_RADIUS = 150.0
const HEX_WIDTH = HEX_RADIUS * 1.73205
const HEX_HEIGHT = HEX_RADIUS * 2.0
const AXIAL_DIRECTIONS = [
	Vector2i(1, 0), Vector2i(1, -1), Vector2i(0, -1),
	Vector2i(-1, 0), Vector2i(-1, 1), Vector2i(0, 1)
]

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	back_button.pressed.connect(_on_back_button_pressed)
	populate_grid()
	GlobalUpgrades.scrap_total_changed.connect(update_scrap_label)
	update_scrap_label(GlobalUpgrades.scrap_total)
	await get_tree().process_frame
	center_on_throne_room()

func _unhandled_input(event: InputEvent):
	if event.is_action_pressed("ui_cancel"):
		queue_free()
		emit_signal("menu_closed")
		get_viewport().set_input_as_handled()

func axial_to_pixel(q: int, r: int) -> Vector2:
	var x = HEX_WIDTH * (float(q) + 0.5 * float(r))
	var y = HEX_HEIGHT * 0.75 * float(r)
	return Vector2(x, y)

func update_scrap_label(_new_total):
	if is_instance_valid(scrap_label):
		scrap_label.text = "Scrap: %d" % GlobalUpgrades.scrap_total
	for child in grid.get_children():
		if child.get_child_count() > 0:
			var button = child.get_node_or_null("ClickableArea")
			if button is Button:
				button.disabled = GlobalUpgrades.scrap_total < GlobalUpgrades.NEW_SLOT_COST
		if child.has_method("update_ui"):
			child.update_ui()

func populate_grid():
	for child in grid.get_children():
		child.queue_free()
	var existing_slots = GlobalUpgrades.grid_layout.keys()
	var potential_new_slots = []
	for axial_coords in existing_slots:
		var room_type = GlobalUpgrades.grid_layout[axial_coords]
		var new_node
		match room_type:
			"throne":
				new_node = THRONE_ROOM_SCENE.instantiate()
			"empty":
				new_node = ROOM_SLOT_SCENE.instantiate()
				new_node.axial_coordinates = axial_coords
				new_node.build_room_requested.connect(on_build_room_requested)
			"damage", "speed", "recovery":
				new_node = UPGRADE_ROOM_SCENE.instantiate()
				if room_type == "damage": new_node.set_script(DamageRoom)
				elif room_type == "speed": new_node.set_script(SpeedRoom)
				elif room_type == "recovery": new_node.set_script(RecoveryRoom)
				new_node.room_demolished.connect(on_room_demolished.bind(axial_coords))
		if is_instance_valid(new_node):
			var pos = axial_to_pixel(axial_coords.x, axial_coords.y)
			new_node.position = pos - new_node.custom_minimum_size / 2.0
			grid.add_child(new_node)
		for direction in AXIAL_DIRECTIONS:
			var neighbor_coords = axial_coords + direction
			if not existing_slots.has(neighbor_coords) and not potential_new_slots.has(neighbor_coords):
				potential_new_slots.append(neighbor_coords)
	for coords in potential_new_slots:
		var panel = PanelContainer.new()
		panel.custom_minimum_size = Vector2(300, 300)
		panel.add_theme_stylebox_override("panel", StyleBoxEmpty.new())
		var poly = Polygon2D.new()
		var center = panel.custom_minimum_size / 2.0
		var hex_points = PackedVector2Array()
		for i in range(6):
			var angle_rad = deg_to_rad(60 * i + 30)
			hex_points.append(center + Vector2(HEX_RADIUS * cos(angle_rad), HEX_RADIUS * sin(angle_rad)))
		poly.polygon = hex_points
		poly.color = Color(0.1, 0.1, 0.1, 0.7)
		panel.add_child(poly)
		var button_label = Label.new()
		button_label.text = "Buy Slot\n(%d Scrap)" % GlobalUpgrades.NEW_SLOT_COST
		button_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		button_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		button_label.autowrap_mode = TextServer.AUTOWRAP_WORD
		button_label.size = panel.custom_minimum_size
		panel.add_child(button_label)
		var clickable_area = Button.new()
		clickable_area.name = "ClickableArea"
		clickable_area.flat = true
		clickable_area.custom_minimum_size = panel.custom_minimum_size
		panel.add_child(clickable_area)
		var pos = axial_to_pixel(coords.x, coords.y)
		panel.position = pos - panel.custom_minimum_size / 2.0
		clickable_area.disabled = GlobalUpgrades.scrap_total < GlobalUpgrades.NEW_SLOT_COST
		clickable_area.pressed.connect(on_buy_new_slot.bind(coords))
		grid.add_child(panel)

func on_build_room_requested(room_type: String, cost: int, axial_coords: Vector2i):
	if GlobalUpgrades.scrap_total < cost:
		return
	GlobalUpgrades.scrap_total -= cost
	GlobalUpgrades.grid_layout[axial_coords] = room_type
	GlobalUpgrades.recalculate_all_stats()
	populate_grid()

func on_room_demolished(refund_amount: int, room_instance: Node, axial_coords: Vector2i):
	GlobalUpgrades.scrap_total += refund_amount
	GlobalUpgrades.grid_layout[axial_coords] = "empty"
	GlobalUpgrades.recalculate_all_stats()
	populate_grid()

func on_buy_new_slot(coords: Vector2i):
	var cost = GlobalUpgrades.NEW_SLOT_COST
	if GlobalUpgrades.scrap_total < cost:
		return
	GlobalUpgrades.scrap_total -= cost
	GlobalUpgrades.grid_layout[coords] = "empty"
	populate_grid()

func center_on_throne_room():
	var throne_room_pos = axial_to_pixel(0, 0)
	var room_view_center = room_view.size / 2.0
	grid.position = room_view_center - throne_room_pos

func _on_back_button_pressed():
	queue_free()
	emit_signal("menu_closed")
