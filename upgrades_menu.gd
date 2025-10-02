extends CanvasLayer

signal menu_closed

# Update the paths to include the new RoomView node
@onready var room_view: Control = $CenterContainer/PanelContainer/VBoxContainer/RoomView
@onready var grid: GridContainer = $CenterContainer/PanelContainer/VBoxContainer/RoomView/GridContainer
@onready var back_button: Button = $CenterContainer/PanelContainer/VBoxContainer/BackButton
@onready var scrap_label: Label = $CenterContainer/PanelContainer/VBoxContainer/ScrapLabel

const ROOM_SLOT_SCENE = preload("res://room_slot.tscn")

var is_panning: bool = false

func _ready():
    process_mode = Node.PROCESS_MODE_ALWAYS
    back_button.pressed.connect(_on_back_button_pressed)
    populate_grid()
    scrap_label.text = "Scrap: %d" % GlobalUpgrades.scrap_total

func populate_grid():
    for i in range(9):
        var slot = ROOM_SLOT_SCENE.instantiate()
        grid.add_child(slot)

func _unhandled_input(event: InputEvent):
    # Check if the mouse is inside our RoomView's rectangle
    var mouse_in_view = room_view.get_global_rect().has_point(event.position)
    
    if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
        # Only start panning if the click is inside the view
        if mouse_in_view:
            is_panning = event.is_pressed()
        else:
            is_panning = false

    if is_panning and event is InputEventMouseMotion:
        # Move the grid's position
        grid.position += event.relative

func _on_back_button_pressed():
    queue_free()
    menu_closed.emit()
