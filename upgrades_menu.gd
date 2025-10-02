# upgrades_menu.gd
extends Node2D

@onready var camera: Camera2D = $Camera2D
@onready var grid: GridContainer = $GridContainer
@onready var back_button: Button = $CanvasLayer/MarginContainer/VBoxContainer/BackButton
@onready var scrap_label: Label = $CanvasLayer/MarginContainer/VBoxContainer/ScrapLabel

const ROOM_SLOT_SCENE = preload("res://room_slot.tscn")

var is_panning: bool = false

func _ready():
    back_button.pressed.connect(_on_back_button_pressed)
    
    populate_grid()
    
    await get_tree().process_frame
    grid.position = -grid.get_rect().size / 2.0
    
    # --- This now correctly displays the global scrap total ---
    scrap_label.text = "Scrap: %d" % GlobalUpgrades.scrap_total

func populate_grid():
    for i in range(9):
        var slot = ROOM_SLOT_SCENE.instantiate()
        grid.add_child(slot)

func _unhandled_input(event: InputEvent):
    if event is InputEventMouseButton:
        if event.is_pressed():
            if event.button_index == MOUSE_BUTTON_WHEEL_UP:
                camera.zoom *= 0.9
            elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
                camera.zoom *= 1.1
    
    if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
        is_panning = event.is_pressed()
            
    if is_panning and event is InputEventMouseMotion:
        camera.position -= event.relative / camera.zoom

func _on_back_button_pressed():
    get_tree().change_scene_to_file("res://main.tscn")
