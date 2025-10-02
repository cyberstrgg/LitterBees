# bee.gd
extends CharacterBody2D

signal scrap_delivered

@export var base_speed: float = 150.0
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
    RETURNING_TO_HIVE,
    RECOVERING
}

var current_state: State

@onready var recovery_timer: Timer = $RecoveryTimer

func _ready():
    add_to_group("bees")
    current_state = State.GOING_TO_TRASH
    wobble_phase_offset = randf_range(0, 2 * PI)

func _physics_process(delta):
    # Speed is calculated every frame to reflect upgrades immediately
    var current_speed = base_speed * GlobalUpgrades.bee_speed_multiplier

    if current_state == State.RECOVERING:
        velocity = Vector2.ZERO
        move_and_slide()
        return

    if bounce_cooldown > 0:
        bounce_cooldown -= delta
    else:
        match current_state:
            State.GOING_TO_TRASH:
                if is_instance_valid(trash_node):
                    move_towards_target(trash_node.global_position, current_speed)
                    
                    if global_position.distance_to(trash_node.global_position) < arrival_threshold:
                        trash_node.take_damage(GlobalUpgrades.bee_damage)
                        is_holding_scrap = true
                        current_state = State.RETURNING_TO_HIVE
                else:
                    reassign_trash_target()
                    
            State.RETURNING_TO_HIVE:
                if is_instance_valid(hive_node):
                    move_towards_target(hive_node.global_position, current_speed)
                    
                    if global_position.distance_to(hive_node.global_position) < arrival_threshold:
                        if is_holding_scrap:
                            scrap_delivered.emit()
                            is_holding_scrap = false
                        
                        current_state = State.RECOVERING
                        recovery_timer.start(GlobalUpgrades.hive_recovery_cooldown)
                else:
                    # If hive is gone, just find new trash.
                    current_state = State.GOING_TO_TRASH
                    reassign_trash_target()
    
    if velocity.length() > 0:
        rotation = velocity.angle() + PI / 2

    move_and_slide()

    for i in range(get_slide_collision_count()):
        var collision = get_slide_collision(i)
        if not collision:
            continue

        var collider = collision.get_collider()
        if collider and collider.is_in_group("bees"):
            var other_bee_state = collider.current_state
            var bounce_normal = collision.get_normal()

            if current_state == State.GOING_TO_TRASH and other_bee_state == State.RETURNING_TO_HIVE:
                velocity = velocity.bounce(bounce_normal) * 0.3
            
            elif current_state == State.RETURNING_TO_HIVE and other_bee_state == State.GOING_TO_TRASH:
                pass
            
            else:
                velocity = velocity.bounce(bounce_normal)

            velocity = velocity.rotated(randf_range(-0.2, 0.2))
            
            bounce_cooldown = 0.1

func _on_recovery_timer_timeout():
    # When the timer finishes, go back to work.
    current_state = State.GOING_TO_TRASH
    reassign_trash_target()

func reassign_trash_target():
    if current_state == State.RETURNING_TO_HIVE:
        return

    var all_trash = get_tree().get_nodes_in_group("trash_nodes")
    var closest_trash: Node2D = null
    var min_distance = INF

    if all_trash.is_empty():
        trash_node = null
        return

    for t in all_trash:
        var distance = global_position.distance_to(t.global_position)
        if distance < min_distance:
            min_distance = distance
            closest_trash = t
    
    trash_node = closest_trash

func move_towards_target(target_position: Vector2, speed: float):
    var direction_to_target = (target_position - global_position).normalized()
    
    var time = Time.get_ticks_msec() / 1000.0
    var wobble_offset = sin(time * wobble_frequency + wobble_phase_offset) * wobble_amplitude
    
    var perpendicular_vec = direction_to_target.orthogonal()
    
    var final_direction = (direction_to_target + perpendicular_vec * wobble_offset).normalized()

    velocity = final_direction * speed
