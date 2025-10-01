# bee.gd
extends CharacterBody2D

@export var speed: float = 150.0
@export var trash_node: Node2D
@export var hive_node: Node2D
@export var arrival_threshold: float = 5.0

enum State {
    GOING_TO_TRASH,
    RETURNING_TO_HIVE
}

var current_state: State

func _ready():
    # A new bee always starts by looking for trash.
    # The main scene will call reassign_trash_target() right after it spawns.
    current_state = State.GOING_TO_TRASH

func _physics_process(delta):
    match current_state:
        State.GOING_TO_TRASH:
            # Check if our target still exists. If not, find a new one.
            if is_instance_valid(trash_node):
                move_towards_target(trash_node.global_position)
                
                if global_position.distance_to(trash_node.global_position) < arrival_threshold:
                    trash_node.take_damage(1)
                    # We've hit the trash, so now we return to the hive.
                    current_state = State.RETURNING_TO_HIVE
            else:
                # Our target was destroyed by another bee! Find a new one.
                reassign_trash_target()
                
        State.RETURNING_TO_HIVE:
            if is_instance_valid(hive_node):
                move_towards_target(hive_node.global_position)
                
                if global_position.distance_to(hive_node.global_position) < arrival_threshold:
                    # We're back at the hive. Time to find more trash.
                    current_state = State.GOING_TO_TRASH
                    reassign_trash_target()
            
    move_and_slide()

# NEW: This is the bee's decision-making function.
func reassign_trash_target():
    # If we are carrying trash back to the hive, IGNORE this call and finish the job.
    if current_state == State.RETURNING_TO_HIVE:
        return

    var all_trash = get_tree().get_nodes_in_group("trash_nodes")
    var closest_trash: Node2D = null
    var min_distance = INF # A special value representing infinity

    # If there's no trash on the map, just go back to the hive.
    if all_trash.is_empty():
        trash_node = null
        current_state = State.RETURNING_TO_HIVE
        return

    # Loop through all trash nodes to find the one closest to us.
    for t in all_trash:
        var distance = global_position.distance_to(t.global_position)
        if distance < min_distance:
            min_distance = distance
            closest_trash = t
    
    # Set the closest trash as our new target.
    trash_node = closest_trash

func move_towards_target(target_position: Vector2):
    var direction = (target_position - global_position).normalized()
    velocity = direction * speed
