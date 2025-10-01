# main.gd
extends Node2D

@export var trash_scene: PackedScene
# NEW: A reference to the bee scene file you just created.
@export var bee_scene: PackedScene
@export var initial_trash_node: Node2D
@export var hive_node: Node2D
@export var camera_node: Camera2D

@export var hive_exclusion_radius: float = 150.0
@export var spawn_padding: float = 64.0

# NEW: This variable will keep track of the current trash target for new bees.
var current_trash_node: Node2D

func _ready():
    # Set the initial trash node as the current one.
    current_trash_node = initial_trash_node
    if is_instance_valid(current_trash_node):
        current_trash_node.trash_destroyed.connect(on_trash_destroyed)

# NEW: This function creates and configures a new bee.
func spawn_bee():
    if not bee_scene: return # Don't do anything if the bee scene isn't set.

    var new_bee = bee_scene.instantiate()
    
    # Set the bee's starting properties.
    # It needs to know where the hive is and what trash to target.
    new_bee.hive_node = hive_node
    new_bee.trash_node = current_trash_node
    
    # Spawn the bee at the hive's location.
    new_bee.global_position = hive_node.global_position
    
    # Add the new bee to a "bees" group to manage them all easily.
    new_bee.add_to_group("bees")
    
    # Add the bee to the scene.
    add_child(new_bee)

func on_trash_destroyed(_old_position: Vector2, new_health: int):
    await get_tree().create_timer(0.2).timeout
    
    var new_trash = trash_scene.instantiate()
    new_trash.health = new_health
    
    # --- SPAWNING LOGIC (Unchanged) ---
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
    
    # UPDATE: Keep track of the newly spawned trash.
    current_trash_node = new_trash
    
    # UPDATE: Instead of telling a single bee, tell ALL bees in the "bees" group
    # to target the new trash.
    get_tree().call_group("bees", "set_new_trash_target", new_trash)

# This is the function connected to your button's "pressed" signal.
func _on_button_pressed():
    spawn_bee()
