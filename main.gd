# main.gd
extends Node2D

@export var trash_scene: PackedScene
@export var bee_node: CharacterBody2D
@export var initial_trash_node: Node2D
@export var hive_node: Node2D

# We need the camera reference again for this method.
@export var camera_node: Camera2D

@export var hive_exclusion_radius: float = 150.0
@export var spawn_padding: float = 64.0

func _ready():
    if initial_trash_node:
        initial_trash_node.trash_destroyed.connect(on_trash_destroyed)

func on_trash_destroyed(_old_position: Vector2, new_health: int):
    await get_tree().create_timer(0.2).timeout
    
    var new_trash = trash_scene.instantiate()
    new_trash.health = new_health
    
    # --- NEW SPAWNING LOGIC ---
    
    # Get the size of your game's viewport (e.g., 1920x1080).
    var view_size = get_viewport().get_visible_rect().size
    var spawn_pos = Vector2.ZERO
    
    # Temporarily add the trash as a child of the camera.
    # This puts it in the camera's local coordinate space.
    camera_node.add_child(new_trash)
    
    while true:
        # Calculate a random position relative to the camera's center.
        var half_size = view_size / 2.0
        spawn_pos.x = randf_range(-half_size.x + spawn_padding, half_size.x - spawn_padding)
        spawn_pos.y = randf_range(-half_size.y + spawn_padding, half_size.y - spawn_padding)
        
        # Set the trash's LOCAL position relative to the camera.
        new_trash.position = spawn_pos
        
        # Check the new GLOBAL position against the hive.
        if new_trash.global_position.distance_to(hive_node.global_position) > hive_exclusion_radius:
            break # This position is valid.

    # "Pin" the trash to the main scene, preserving its global position.
    new_trash.reparent(self)

    new_trash.trash_destroyed.connect(on_trash_destroyed)
    
    if is_instance_valid(bee_node):
        bee_node.set_new_trash_target(new_trash)
