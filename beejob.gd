# bee.gd
extends CharacterBody2D

signal scrap_delivered

@export var speed: float = 150.0
@export var trash_node: Node2D
@export var hive_node: Node2D
@export var arrival_threshold: float = 5.0

# --- Gameplay Tweak Variables ---
@export var wobble_frequency: float = 5.0 # How fast the bee wobbles
@export var wobble_amplitude: float = 0.5 # How far the bee wobbles side-to-side

# --- Internal State Variables ---
var is_holding_scrap = false
var bounce_cooldown: float = 0.0
var wobble_phase_offset: float = 0.0 # Randomizes the wobble pattern per bee

enum State {
    GOING_TO_TRASH,
    RETURNING_TO_HIVE
}

var current_state: State

func _ready():
    # Add the bee to its group so the main scene can find it.
    add_to_group("bees")
    current_state = State.GOING_TO_TRASH
    # Give each bee a random starting point in its wobble cycle
    wobble_phase_offset = randf_range(0, 2 * PI)

func _physics_process(delta):
    # If on cooldown, just count down and don't run the logic below.
    if bounce_cooldown > 0:
        bounce_cooldown -= delta
    else:
        # Standard movement logic only runs when not on cooldown.
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
                            print("Bee at hive with scrap, emitting signal.")
                            scrap_delivered.emit()
                            is_holding_scrap = false
                        
                        current_state = State.GOING_TO_TRASH
                        reassign_trash_target()
    
    # Rotate the bee to face its direction of movement
    if velocity.length() > 0:
        # For sprites that face up
        rotation = velocity.angle() + PI / 2
        # NOTE: If your bee sprite faces UP instead of RIGHT, uncomment the line below
        # rotation += PI / 2

    move_and_slide()

    # Collision check remains the same, but now it SETS the cooldown.
    for i in range(get_slide_collision_count()):
        var collision = get_slide_collision(i)
        if not collision:
            continue

        var collider = collision.get_collider()
        if collider and collider.is_in_group("bees"):
            var other_bee_state = collider.current_state
            var bounce_normal = collision.get_normal()

            if current_state == State.RETURNING_TO_HIVE and other_bee_state == State.GOING_TO_TRASH:
                velocity = velocity.bounce(bounce_normal) * .3
            elif current_state == State.GOING_TO_TRASH and other_bee_state == State.RETURNING_TO_HIVE:
                velocity = velocity.bounce(bounce_normal) * .6
            else:
                velocity = velocity.bounce(bounce_normal)
    
            velocity = velocity.rotated(randf_range(-0.2, 0.2))
            
            # Start the cooldown so the bounce is visible
            bounce_cooldown = 0.1

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
    # The original direction towards the target
    var direction_to_target = (target_position - global_position).normalized()
    
    # Use time and a random offset to create a unique sine wave for the wobble effect
    var time = Time.get_ticks_msec() / 1000.0
    var wobble_offset = sin(time * wobble_frequency + wobble_phase_offset) * wobble_amplitude
    
    # Get a vector that is perpendicular to the direction of travel
    var perpendicular_vec = direction_to_target.orthogonal()
    
    # Combine the forward direction with the sideways wobble and normalize it
    var final_direction = (direction_to_target + perpendicular_vec * wobble_offset).normalized()

    # Set the final velocity
    velocity = final_direction * speed
