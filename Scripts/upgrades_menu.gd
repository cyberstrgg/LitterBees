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
    for i in range(9):
        var slot
        # Check if the current slot is the middle one (index 4)
        if i == 4:
            slot = THRONE_ROOM_SCENE.instantiate()
        else:
            slot = ROOM_SLOT_SCENE.instantiate()
            # Connect the build signal from the empty slot
            slot.build_room_requested.connect(on_build_room_requested)
        grid.add_child(slot)

func on_build_room_requested(room_type: String, cost: int, slot_instance: Node):
    if GlobalUpgrades.scrap_total < cost:
        print("Not enough scrap to build!")
        return
    
    GlobalUpgrades.scrap_total -= cost
    
    # Create an instance of the generic upgrade room scene
    var new_room = UPGRADE_ROOM_SCENE.instantiate()
    
    # Attach the correct specific script based on the chosen type
    match room_type:
        "damage":
            new_room.set_script(DamageRoom)
        "speed":
            new_room.set_script(SpeedRoom)
        "recovery":
            new_room.set_script(RecoveryRoom)
    
    # Connect the demolish signal from the new room
    new_room.room_demolished.connect(on_room_demolished)
    
    # Replace the old slot with the new room in the grid
    var slot_index = slot_instance.get_index()
    grid.add_child(new_room)
    grid.move_child(new_room, slot_index)
    slot_instance.queue_free()
    
    update_scrap_label()

func on_room_demolished(refund_amount: int, room_instance: Node):
    GlobalUpgrades.scrap_total += refund_amount
    
    # Create a new empty slot to replace the demolished room
    var new_slot = ROOM_SLOT_SCENE.instantiate()
    new_slot.build_room_requested.connect(on_build_room_requested)
    
    # Place the new slot where the old room was
    var room_index = room_instance.get_index()
    grid.add_child(new_slot)
    grid.move_child(new_slot, room_index)
    # The room instance queue_free()s itself when demolished
    
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
