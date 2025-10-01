# main_scene.gd
extends Node2D

# Assign your 'trash.tscn' file to this in the Inspector.
@export var trash_scene: PackedScene

# A reference to the bee so we can tell it where the new trash is.
@export var bee_node: CharacterBody2D

func _ready():
	# Find the first trash instance that's already in the scene.
	var initial_trash = find_child("Trash")
	if initial_trash:
		# Connect its "destroyed" signal to our respawn function.
		initial_trash.trash_destroyed.connect(on_trash_destroyed)

# This function is called when the trash emits the 'trash_destroyed' signal.
func on_trash_destroyed(spawn_position: Vector2):
	# Wait for 0.2 seconds before respawning.
	await get_tree().create_timer(0.2).timeout
	
	# Create a new instance of the trash scene.
	var new_trash = trash_scene.instantiate()
	
	# Add the new trash to the scene and set its position.
	add_child(new_trash)
	new_trash.global_position = spawn_position
	
	# IMPORTANT: Connect the signal for the NEW trash instance as well.
	new_trash.trash_destroyed.connect(on_trash_destroyed)
	
	# Tell the bee about the new trash target.
	if is_instance_valid(bee_node):
		bee_node.set_new_trash_target(new_trash)
