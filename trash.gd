# trash.gd
extends Node2D

# A signal to notify the main scene when this trash is destroyed.
# We'll also pass back its position so the new one spawns in the same place.
signal trash_destroyed(spawn_position)

@export var health: int = 10

# This function is called by the bee.
func take_damage(amount: int):
	health -= amount
	print("Trash was hit! Health is now: %d" % health) # For debugging
	
	# If health is 0 or less, destroy the trash.
	if health <= 0:
		# Emit the signal before disappearing.
		emit_signal("trash_destroyed", global_position)
		# Remove the node from the scene.
		queue_free()
