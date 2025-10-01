# bee.gd
extends CharacterBody2D

@export var speed: float = 150.0
@export var trash_node: Node2D
@export var hive_node: Node2D
@export var arrival_threshold: float = 5.0

# The bee now works in a loop.
enum State {
    GOING_TO_TRASH,
    RETURNING_TO_HIVE
}

var current_state: State

func _ready():
    current_state = State.GOING_TO_TRASH

func _physics_process(delta):
    match current_state:
        State.GOING_TO_TRASH:
            if is_instance_valid(trash_node):
                move_towards_target(trash_node.global_position)
                
                # Check for arrival at the trash.
                if global_position.distance_to(trash_node.global_position) < arrival_threshold:
                    # "Hit" the trash by calling its function.
                    trash_node.take_damage(1)
                    # Change state to go back to the hive.
                    current_state = State.RETURNING_TO_HIVE
            else:
                # If the trash doesn't exist for some reason, just return to hive.
                current_state = State.RETURNING_TO_HIVE
                
        State.RETURNING_TO_HIVE:
            if is_instance_valid(hive_node):
                move_towards_target(hive_node.global_position)
                
                # Check for arrival at the hive.
                if global_position.distance_to(hive_node.global_position) < arrival_threshold:
                    # Once at the hive, go back for more trash. This creates the loop.
                    current_state = State.GOING_TO_TRASH
            
    move_and_slide()

# This function is called by the main scene when trash respawns.
func set_new_trash_target(new_trash: Node2D):
    trash_node = new_trash
    # Immediately go after the new trash.

func move_towards_target(target_position: Vector2):
    var direction = (target_position - global_position).normalized()
    velocity = direction * speed
