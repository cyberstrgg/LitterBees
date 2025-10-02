# recovery_room.gd
extends "res://Scripts/UpgradeRooms/base_upgrade_room.gd"

# Each level reduces recovery time by 5% (i.e., multiplies by 0.95)
var recovery_multiplier_per_level: float = 0.95

func _ready():
    room_name = "Nursery"
    base_cost = 50
    cost_multiplier = 1.7
    super._ready()

func apply_upgrade_effect():
    GlobalUpgrades.add_recovery_multiplier(recovery_multiplier_per_level)

func revert_all_effects():
    for i in range(level):
        GlobalUpgrades.remove_recovery_multiplier(recovery_multiplier_per_level)

func get_effect_description() -> String:
    return "Reduces bee rest time\n(Total Cooldown: %.2fs)" % GlobalUpgrades.hive_recovery_cooldown
