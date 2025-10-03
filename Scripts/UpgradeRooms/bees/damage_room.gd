# damage_room.gd
extends "res://Scripts/UpgradeRooms/base_upgrade_room.gd"

func _ready():
    room_name = "Barracks"
    base_cost = 40
    cost_multiplier = 1.6
    # Call the base class's _ready function
    super._ready()
    # Set a placeholder color for the damage room
    polygon_2d.color = Color(0.6, 0.2, 0.2)

func get_effect_description() -> String:
    # This now correctly reads the global value calculated by GlobalUpgrades
    return "Increases bee damage\n(Total Damage: %d)" % GlobalUpgrades.bee_damage
