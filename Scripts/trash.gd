# trash.gd
extends Node2D

signal trash_destroyed(spawn_position, initial_health)

@export var health: int = 10
var max_health: int

func _ready():
    max_health = health
    # Add this line so bees can find all available trash.
    add_to_group("trash_nodes")

func take_damage(amount: int):
    health -= amount
    if health <= 0:
        emit_signal("trash_destroyed", global_position, max_health)
        queue_free()
