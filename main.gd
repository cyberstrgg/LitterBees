# main.gd
extends Node2D

@export var trash_scene: PackedScene
@export var bee_node: CharacterBody2D
@export var initial_trash_node: Node2D

# DRAG AND DROP your hive node from the scene tree here.
@export var hive_node: Node2D
# How close trash is allowed to spawn to the hive.
@export var hive_exclusion_radius: float = 150.0

func _ready():
    if initial_trash_node:
        initial_trash_node.trash_destroyed.connect(on_trash_destroyed)

# This function is now passed the starting health of the trash that was destroyed.
func on_trash_destroyed(_old_position: Vector2, new_health: int):
    await get_tree().create_timer(0.2).timeout
    
    var new_trash = trash_scene.instantiate()
    
    # Set the health of the new trash to match the old one.
    new_trash.health = new_health
    
    # --- Find a new random spawn position ---
    var screen_size = get_viewport_rect().size
    var new_spawn_pos = Vector2.ZERO
    
    # Loop until we find a position that is not too close to the hive.
    while true:
        new_spawn_pos.x = randf_range(0, screen_size.x)
        new_spawn_pos.y = randf_range(0, screen_size.y)
        
        if new_spawn_pos.distance_to(hive_node.global_position) > hive_exclusion_radius:
            break # This position is valid, so we exit the loop.
            
    add_child(new_trash)
    new_trash.global_position = new_spawn_pos
    
    new_trash.trash_destroyed.connect(on_trash_destroyed)
    
    if is_instance_valid(bee_node):
        bee_node.set_new_trash_target(new_trash)
