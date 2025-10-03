# Scripts/main.gd
extends Node2D

@export var upgrades_menu_scene: PackedScene
@export var shop_menu_scene: PackedScene
@export var trash_scene: PackedScene
@export var bee_scene: PackedScene
@export var initial_trash_node: Node2D
@export var hive_node: Node2D
@export var camera_node: Camera2D
@export var score_label: Label
@export var shop_button: Button

@export var hive_exclusion_radius: float = 150.0
@export var spawn_padding: float = 64.0

func _ready():
	if is_instance_valid(initial_trash_node):
		initial_trash_node.trash_destroyed.connect(on_trash_destroyed)
	
	update_score_label()

	await get_tree().process_frame
	var initial_bees = get_tree().get_nodes_in_group("bees")
	for bee in initial_bees:
		connect_bee_signals(bee)
	
	get_tree().call_group("bees", "reassign_trash_target")

func connect_bee_signals(bee_node):
	if not bee_node.is_connected("scrap_delivered", on_scrap_delivered):
		bee_node.scrap_delivered.connect(on_scrap_delivered)

func on_scrap_delivered():
	GlobalUpgrades.scrap_total += 1
	update_score_label()

func update_score_label():
	if is_instance_valid(score_label):
		score_label.text = "Scrap: %d" % GlobalUpgrades.scrap_total

func spawn_bee(bee_type: String = "standard_bee"):
	if not bee_scene: return

	var new_bee = bee_scene.instantiate()
	new_bee.hive_node = hive_node
	
	connect_bee_signals(new_bee)
	
	new_bee.global_position = hive_node.global_position
	add_child(new_bee)
	
	new_bee.reassign_trash_target()

func on_trash_destroyed(_old_position: Vector2, new_health: int):
	await get_tree().create_timer(0.2).timeout
	
	var new_trash = trash_scene.instantiate()
	new_trash.health = new_health
	
	var view_size = get_viewport().get_visible_rect().size
	var spawn_pos = Vector2.ZERO
	camera_node.add_child(new_trash)
	while true:
		var half_size = view_size / 2.0
		spawn_pos.x = randf_range(-half_size.x + spawn_padding, half_size.x - spawn_padding)
		spawn_pos.y = randf_range(-half_size.y + spawn_padding, half_size.y - spawn_padding)
		new_trash.position = spawn_pos
		if new_trash.global_position.distance_to(hive_node.global_position) > hive_exclusion_radius:
			break
	new_trash.reparent(self)

	new_trash.trash_destroyed.connect(on_trash_destroyed)
	
	get_tree().call_group("bees", "reassign_trash_target")

func _on_shop_button_pressed():
	var existing_menu = get_tree().get_first_node_in_group("shop_menu")
	if existing_menu:
		existing_menu.queue_free()
	else:
		var menu = shop_menu_scene.instantiate()
		menu.add_to_group("shop_menu")
		menu.bee_purchased.connect(spawn_bee)
		add_child(menu)

func _on_upgrades_button_pressed():
	var existing_menu = get_tree().get_first_node_in_group("upgrades_menu")
	if existing_menu:
		existing_menu.queue_free()
	else:
		var menu = upgrades_menu_scene.instantiate()
		menu.add_to_group("upgrades_menu")
		add_child(menu)
