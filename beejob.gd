# bee.gd
extends CharacterBody2D

## --- Variables ---
# You can set these values in the Inspector panel in the Godot editor.

# How fast the bee moves in pixels per second.
@export var speed: float = 150.0

# Link to the Trash node in your scene.
@export var trash_node: Node2D

# Link to the Hive node in your scene.
@export var hive_node: Node2D

# How close the bee needs to be to a target to consider it "arrived".
@export var arrival_threshold: float = 5.0

# This enum defines the possible states for our bee.
enum State {
	IDLE,
	GOING_TO_TRASH,
	GOING_TO_HIVE
}

# This variable holds the bee's current state.
var current_state: State


## --- Godot Functions ---

# This function is called once when the node enters the scene tree.
func _ready():
	# Start the bee's mission as soon as it spawns.
	current_state = State.GOING_TO_TRASH

# This function is called every physics frame.
func _physics_process(delta):
	# The 'match' statement checks the bee's current state and runs the
	# corresponding logic for that state.
	match current_state:
		State.IDLE:
			# If idle, do nothing. Stop moving.
			velocity = Vector2.ZERO
			
		State.GOING_TO_TRASH:
			# Check if the trash node still exists before moving towards it.
			if is_instance_valid(trash_node):
				move_towards_target(trash_node.global_position)
				
				# Check if we have arrived at the trash.
				if global_position.distance_to(trash_node.global_position) < arrival_threshold:
					# "Remove" the trash by deleting it from the scene.
					trash_node.queue_free()
					# Change state to go to the hive next.
					current_state = State.GOING_TO_HIVE
			else:
				# If trash is already gone, just go to the hive.
				current_state = State.GOING_TO_HIVE
				
		State.GOING_TO_HIVE:
			# Check if the hive node exists before moving towards it.
			if is_instance_valid(hive_node):
				move_towards_target(hive_node.global_position)
				
				# Check if we have arrived at the hive.
				if global_position.distance_to(hive_node.global_position) < arrival_threshold:
					# We've completed the task. Go idle.
					current_state = State.IDLE
					print("Bee has returned to the hive!") # Optional message
			else:
				# If the hive doesn't exist, just go idle.
				current_state = State.IDLE
				
	# This is the built-in function that actually moves the character.
	move_and_slide()


## --- Custom Functions ---

# A helper function to handle the movement logic.
func move_towards_target(target_position: Vector2):
	# Calculate the direction from the bee to the target.
	var direction = (target_position - global_position).normalized()
	# Set the velocity to move in that direction at the defined speed.
	velocity = direction * speed
