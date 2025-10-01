# main.gd
extends Node2D

@export var trash_scene: PackedScene
@export var bee_scene: PackedScene
@export var initial_trash_node: Node2D
@export var hive_node: Node2D
@export var camera_node: Camera2D
@export var score_label: Label

@export var hive_exclusion_radius: float = 150.0
# This line must be present for the error to go away.
@export var spawn_padding: float = 64.0

var scrap_total = 0

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
    scrap_total += 1
    update_score_label()
    print("Signal received! Scrap total is now: %d" % scrap_total)

func update_score_label():
    if is_instance_valid(score_label):
        score_label.text = "Scrap: %d" % scrap_total

func spawn_bee():
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

func _on_button_pressed():
    spawn_bee()
