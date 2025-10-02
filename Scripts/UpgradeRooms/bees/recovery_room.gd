# recovery_room.gd
extends "res://Scripts/UpgradeRooms/base_upgrade_room.gd"

func _ready():
    room_name = "Nursery"
    base_cost = 50
    cost_multiplier = 1.7
    super._ready()

func get_effect_description() -> String:
    # This function is still useful for displaying the current stat in the UI
    return "Reduces bee rest time\n(Total Cooldown: %.2fs)" % GlobalUpgrades.hive_recovery_cooldown
