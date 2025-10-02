# The root node is now a CanvasLayer
extends CanvasLayer

# --- Add a signal to let the main scene know when we close ---
signal menu_closed

# References to nodes are the same
@onready var grid: GridContainer = $GridContainer
@onready var back_button: Button = $MarginContainer/VBoxContainer/BackButton
@onready var scrap_label: Label = $MarginContainer/VBoxContainer/ScrapLabel

const ROOM_SLOT_SCENE = preload("res://room_slot.tscn")

var is_panning: bool = false
# You no longer need the camera variable, so it has been removed.

func _ready():
    back_button.pressed.connect(_on_back_button_pressed)
    populate_grid()
    await get_tree().process_frame
    grid.position = -grid.get_rect().size / 2.0
    scrap_label.text = "Scrap: %d" % GlobalUpgrades.scrap_total

func populate_grid():
    for i in range(9):
        var slot = ROOM_SLOT_SCENE.instantiate()
        grid.add_child(slot)

func _unhandled_input(event: InputEvent):
    # Panning no longer requires a camera reference. Godot's input events
    # work on the viewport, so we can pan the grid container's contents directly.
    # Note: This is a different way to pan, suited for UI.
    if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
        is_panning = event.is_pressed()
            
    if is_panning and event is InputEventMouseMotion:
        # Move the grid itself instead of a camera
        grid.position += event.relative

func _on_back_button_pressed():
    # --- CRITICAL CHANGE ---
    # Instead of changing scenes, just remove this UI layer from existence.
    queue_free()
    # Emit the signal so the main scene can unpause the game
    menu_closed.emit()
