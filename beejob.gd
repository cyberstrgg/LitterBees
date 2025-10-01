extends CharacterBody2D

# --- Variables ---
# You will drag-and-drop your nodes onto these slots in the Inspector.
@export var trash_pile_node: Node2D
@export var garbage_node: Sprite2D

# NPC's movement speed.
@export var speed: float = 150.0

# An enum to define the NPC's possible states.
enum State { MOVING_TO_TRASH, MOVING_TO_CENTER, IDLE }

# The NPC's current state.
var current_state: State

# The positions the NPC will move between.
var center_position: Vector2
var trash_position: Vector2

# --- Godot Functions ---

# This function runs once when the scene starts.
func _ready() -> void:
	# Calculate the center of the screen.
	center_position = get_viewport_rect().size / 2
	
	# Set the NPC's starting position to the center.
	global_position = center_position
	
	# Get the trash pile's global position.
	trash_position = trash_pile_node.global_position
	
	# Hide the garbage just in case it's visible.
	garbage_node.visible = false
	
	# Start the behavior by telling the NPC to go to the trash.
	current_state = State.MOVING_TO_TRASH

# This function runs on every physics frame (best for movement).
func _physics_process(_delta: float) -> void:
	# A 'match' statement works like a big if/else block for our states.
	match current_state:
		State.MOVING_TO_TRASH:
			move_to(trash_position)
			# If we are very close to the trash pile...
			if global_position.distance_to(trash_position) < 5.0:
				pick_up_garbage()
				current_state = State.MOVING_TO_CENTER
				
		State.MOVING_TO_CENTER:
			move_to(center_position)
			# If we are very close to the center...
			if global_position.distance_to(center_position) < 5.0:
				velocity = Vector2.ZERO # Stop moving.
				current_state = State.IDLE
				
		State.IDLE:
			# Do nothing. The NPC has completed its task.
			velocity = Vector2.ZERO

# --- Custom Functions ---

# Handles the movement logic.
func move_to(target_position: Vector2) -> void:
	# Calculate the direction from the NPC to the target.
	var direction = global_position.direction_to(target_position)
	# Set the velocity to move in that direction.
	velocity = direction * speed
	# Godot's built-in function to handle movement and collision.
	move_and_slide()

# Handles the logic for "picking up" the garbage.
func pick_up_garbage() -> void:
	# Move the garbage from the main scene to be a child of the NPC.
	# This makes the garbage move with the NPC.
	get_parent().remove_child(garbage_node)
	add_child(garbage_node)
	
	# Make the garbage visible.
	garbage_node.visible = true
	# Set its position relative to the NPC (e.g., slightly above it).
	garbage_node.position = Vector2(0, -30)
