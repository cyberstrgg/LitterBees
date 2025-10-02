extends CanvasLayer

signal menu_closed

# The reference to room_view is no longer needed here
@onready var grid: GridContainer = $CenterContainer/PanelContainer/VBoxContainer/RoomView/GridContainer
@onready var back_button: Button = $CenterContainer/PanelContainer/VBoxContainer/BackButton
@onready var scrap_label: Label = $CenterContainer/PanelContainer/VBoxContainer/ScrapLabel

const ROOM_SLOT_SCENE = preload("res://room_slot.tscn")

func _ready():
    process_mode = Node.PROCESS_MODE_ALWAYS
    back_button.pressed.connect(_on_back_button_pressed)
    populate_grid()
    scrap_label.text = "Scrap: %d" % GlobalUpgrades.scrap_total

func populate_grid():
    for i in range(9):
        var slot = ROOM_SLOT_SCENE.instantiate()
        grid.add_child(slot)

func _on_back_button_pressed():
    queue_free()
    menu_closed.emit()
