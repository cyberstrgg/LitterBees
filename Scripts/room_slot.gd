# room_slot.gd
extends PanelContainer

signal build_room_requested(room_type, cost, slot_instance)

# Preload the scripts to get their base costs
const DamageRoom = preload("res://Scripts/UpgradeRooms/bees/damage_room.gd")
const SpeedRoom = preload("res://Scripts/UpgradeRooms/bees/speed_room.gd")
const RecoveryRoom = preload("res://Scripts/UpgradeRooms/bees/recovery_room.gd")

@onready var build_menu = $BuildMenu
@onready var build_button = $BuildButton
@onready var build_damage_button = $BuildMenu/VBoxContainer/BuildDamageButton
@onready var build_speed_button = $BuildMenu/VBoxContainer/BuildSpeedButton
@onready var build_recovery_button = $BuildMenu/VBoxContainer/BuildRecoveryButton

var damage_cost: int
var speed_cost: int
var recovery_cost: int

func _ready():
    # Connect signals
    build_button.pressed.connect(_on_build_button_pressed)
    build_damage_button.pressed.connect(_on_build_room_type_pressed.bind("damage"))
    build_speed_button.pressed.connect(_on_build_room_type_pressed.bind("speed"))
    build_recovery_button.pressed.connect(_on_build_room_type_pressed.bind("recovery"))
    
    # Get base costs from the scripts
    damage_cost = DamageRoom.new().base_cost
    speed_cost = SpeedRoom.new().base_cost
    recovery_cost = RecoveryRoom.new().base_cost
    
    update_button_text()

func update_button_text():
    build_damage_button.text = "Barracks (%d)" % damage_cost
    build_speed_button.text = "Apiary (%d)" % speed_cost
    build_recovery_button.text = "Nursery (%d)" % recovery_cost

func _on_build_button_pressed():
    build_menu.visible = true
    build_button.visible = false

func _on_build_room_type_pressed(type: String):
    match type:
        "damage":
            emit_signal("build_room_requested", "damage", damage_cost, self)
        "speed":
            emit_signal("build_room_requested", "speed", speed_cost, self)
        "recovery":
            emit_signal("build_room_requested", "recovery", recovery_cost, self)
    
    # No need to change visibility here, as this node will be replaced

# Allows the player to right-click to close the build menu
func _gui_input(event: InputEvent):
    if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.is_pressed():
        if build_menu.visible:
            build_menu.visible = false
            build_button.visible = true
            get_viewport().set_input_as_handled()
