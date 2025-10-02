extends CanvasLayer

signal menu_closed

# Get references to the RoomView control and the grid
@onready var room_view: Control = $CenterContainer/PanelContainer/VBoxContainer/RoomView
@onready var grid: GridContainer = $CenterContainer/PanelContainer/VBoxContainer/RoomView/GridContainer
@onready var back_button: Button = $CenterContainer/PanelContainer/VBoxContainer/BackButton
@onready var scrap_label: Label = $CenterContainer/PanelContainer/VBoxContainer/ScrapLabel

# Preload both the standard room slot and your new throne room
const ROOM_SLOT_SCENE = preload("res://Scenes/room_slot.tscn")
const THRONE_ROOM_SCENE = preload("res://Scenes/throne_room.tscn")

func _ready():
    process_mode = Node.PROCESS_MODE_ALWAYS
    back_button.pressed.connect(_on_back_button_pressed)
    
    populate_grid()
    scrap_label.text = "Scrap: %d" % GlobalUpgrades.scrap_total
    
    # We must wait one frame for the control nodes to report their correct sizes.
    await get_tree().process_frame
    center_on_throne_room()

func populate_grid():
    for i in range(9):
        var slot
        # Check if the current slot is the middle one (index 4)
        if i == 4:
            slot = THRONE_ROOM_SCENE.instantiate()
        else:
            slot = ROOM_SLOT_SCENE.instantiate()
        grid.add_child(slot)

func center_on_throne_room():
    # The throne room is the 5th child added to the grid (index 4)
    var throne_room = grid.get_child(4)
    
    # Calculate the center of the throne room relative to the grid's origin
    var throne_room_center = throne_room.position + throne_room.size / 2.0
    
    # Calculate the center of the viewport/panning area
    var room_view_center = room_view.size / 2.0
    
    # Set the grid's position to align the two centers
    grid.position = room_view_center - throne_room_center

func _on_back_button_pressed():
    queue_free()
    menu_closed.emit()
