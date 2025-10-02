# damage_room.gd
extends "res://Scripts/UpgradeRooms/base_upgrade_room.gd"

func _ready():
    room_name = "Barracks"
    base_cost = 40
    cost_multiplier = 1.6
    # Call the base class's _ready function
    super._ready()

func get_effect_description() -> String:
    # This now correctly reads the global value calculated by GlobalUpgrades
    return "Increases bee damage\n(Total Damage: %d)" % GlobalUpgrades.bee_damage
