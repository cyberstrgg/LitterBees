# trash.gd
extends Node2D

# We'll pass back its position and starting health.
signal trash_destroyed(spawn_position, initial_health)

@export var health: int = 10
var max_health: int

func _ready():
    # Store the health value set in the Inspector so we can remember it.
    max_health = health

# This function is called by the bee.
func take_damage(amount: int):
    health -= amount
    print("Trash was hit! Health is now: %d" % health) # For debugging
    
    # If health is 0 or less, destroy the trash.
    if health <= 0:
        # Emit the signal with the original max_health.
        emit_signal("trash_destroyed", global_position, max_health)
        # Remove the node from the scene.
        queue_free()
