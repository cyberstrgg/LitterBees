# bee.gd
extends CharacterBody2D

signal scrap_delivered

@export var speed: float = 150.0
@export var trash_node: Node2D
@export var hive_node: Node2D
@export var arrival_threshold: float = 5.0

var is_holding_scrap = false

enum State {
    GOING_TO_TRASH,
    RETURNING_TO_HIVE
}

var current_state: State

func _ready():
    # Add the bee to its group so the main scene can find it.
    add_to_group("bees")
    current_state = State.GOING_TO_TRASH

func _physics_process(delta):
    match current_state:
        State.GOING_TO_TRASH:
            if is_instance_valid(trash_node):
                move_towards_target(trash_node.global_position)
                
                if global_position.distance_to(trash_node.global_position) < arrival_threshold:
                    trash_node.take_damage(1)
                    is_holding_scrap = true
                    current_state = State.RETURNING_TO_HIVE
            else:
                reassign_trash_target()
                
        State.RETURNING_TO_HIVE:
            if is_instance_valid(hive_node):
                move_towards_target(hive_node.global_position)
                
                if global_position.distance_to(hive_node.global_position) < arrival_threshold:
                    if is_holding_scrap:
                        # Print statement to confirm the signal is being sent.
                        print("Bee at hive with scrap, emitting signal.")
                        scrap_delivered.emit()
                        is_holding_scrap = false
                    
                    current_state = State.GOING_TO_TRASH
                    reassign_trash_target()
            
    move_and_slide()

func reassign_trash_target():
    if current_state == State.RETURNING_TO_HIVE:
        return

    var all_trash = get_tree().get_nodes_in_group("trash_nodes")
    var closest_trash: Node2D = null
    var min_distance = INF

    if all_trash.is_empty():
        trash_node = null
        current_state = State.RETURNING_TO_HIVE
        return

    for t in all_trash:
        var distance = global_position.distance_to(t.global_position)
        if distance < min_distance:
            min_distance = distance
            closest_trash = t
    
    trash_node = closest_trash

func move_towards_target(target_position: Vector2):
    var direction = (target_position - global_position).normalized()
    velocity = direction * speed
