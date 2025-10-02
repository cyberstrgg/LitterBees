# upgrades_menu.gd
extends CanvasLayer

signal menu_closed

# Get references to the RoomView control and the grid
@onready var room_view: Control = $CenterContainer/PanelContainer/VBoxContainer/RoomView
@onready var grid: GridContainer = $CenterContainer/PanelContainer/VBoxContainer/RoomView/GridContainer
@onready var back_button: Button = $CenterContainer/PanelContainer/VBoxContainer/BackButton
@onready var scrap_label: Label = $CenterContainer/PanelContainer/VBoxContainer/ScrapLabel

# Preload all room scenes and scripts
const ROOM_SLOT_SCENE = preload("res://Scenes/room_slot.tscn")
const THRONE_ROOM_SCENE = preload("res://Scenes/throne_room.tscn")
const UPGRADE_ROOM_SCENE = preload("res://Scenes/UpgradeRooms/upgrade_room.tscn")

# Keep references to the specific room scripts
const DamageRoom = preload("res://Scripts/UpgradeRooms/bees/damage_room.gd")
const SpeedRoom = preload("res://Scripts/UpgradeRooms/bees/speed_room.gd")
const RecoveryRoom = preload("res://Scripts/UpgradeRooms/bees/recovery_room.gd")


func _ready():
    process_mode = Node.PROCESS_MODE_ALWAYS
    back_button.pressed.connect(_on_back_button_pressed)
    # This connection is for updating the scrap label in the menu
    # if scrap is gained/lost while the menu is open.
    get_tree().create_timer(0.1).connect("timeout", update_scrap_label.bind(), CONNECT_ONE_SHOT)
    
    populate_grid()
    update_scrap_label()
    
    # We must wait one frame for the control nodes to report their correct sizes.
    await get_tree().process_frame
    center_on_throne_room()

func update_scrap_label():
    if is_instance_valid(scrap_label):
        scrap_label.text = "Scrap: %d" % GlobalUpgrades.scrap_total
    # Update all buttons in the grid to reflect current scrap count
    for room in grid.get_children():
        if room.has_method("update_ui"):
            room.update_ui()

func populate_grid():
    # Clear any existing children before rebuilding
    for child in grid.get_children():
        child.queue_free()
    
    # Rebuild the grid based on the saved layout in GlobalUpgrades
    for room_type in GlobalUpgrades.grid_layout:
        var new_node

        match room_type:
            "throne":
                new_node = THRONE_ROOM_SCENE.instantiate()
            "empty":
                new_node = ROOM_SLOT_SCENE.instantiate()
                new_node.build_room_requested.connect(on_build_room_requested)
            "damage", "speed", "recovery":
                new_node = UPGRADE_ROOM_SCENE.instantiate()
                # Attach the correct specific script
                if room_type == "damage":
                    new_node.set_script(DamageRoom)
                elif room_type == "speed":
                    new_node.set_script(SpeedRoom)
                elif room_type == "recovery":
                    new_node.set_script(RecoveryRoom)
                new_node.room_demolished.connect(on_room_demolished)
        
        if is_instance_valid(new_node):
            grid.add_child(new_node)


func on_build_room_requested(room_type: String, cost: int, slot_instance: Node):
    if GlobalUpgrades.scrap_total < cost:
        print("Not enough scrap to build!")
        return
    
    GlobalUpgrades.scrap_total -= cost
    
    # Update the global state
    var slot_index = slot_instance.get_index()
    GlobalUpgrades.grid_layout[slot_index] = room_type
    
    # Call the new central function
    GlobalUpgrades.recalculate_all_stats()
    
    # Rebuild the visual grid and update UI
    populate_grid()
    update_scrap_label()


func on_room_demolished(refund_amount: int, room_instance: Node):
    GlobalUpgrades.scrap_total += refund_amount
    
    # Update the global state
    var room_index = room_instance.get_index()
    GlobalUpgrades.grid_layout[room_index] = "empty"

    # Call the new central function
    GlobalUpgrades.recalculate_all_stats()
    
    # Rebuild the visual grid and update UI
    populate_grid()
    update_scrap_label()


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
    emit_signal("menu_closed")
