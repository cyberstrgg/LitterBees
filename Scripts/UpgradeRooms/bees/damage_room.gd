# damage_room.gd
extends "res://Scripts/UpgradeRooms/base_upgrade_room.gd"

var damage_per_level: int = 1

func _ready():
    room_name = "Barracks"
    base_cost = 40
    cost_multiplier = 1.6
    # Call the base class's _ready function
    super._ready()

func apply_upgrade_effect():
    # Called on initial build and every upgrade
    GlobalUpgrades.add_damage_bonus(damage_per_level)

func revert_all_effects():
    # Called only on demolish
    var total_damage_bonus = level * damage_per_level
    GlobalUpgrades.remove_damage_bonus(total_damage_bonus)

func get_effect_description() -> String:
    var total_bonus = level * damage_per_level
    return "Adds +%d Damage\n(Total Bee Damage: %d)" % [total_bonus, GlobalUpgrades.bee_damage]
