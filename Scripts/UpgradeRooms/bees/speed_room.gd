# speed_room.gd
extends "res://Scripts/UpgradeRooms/base_upgrade_room.gd"

# Each level adds a 10% speed multiplier
var speed_multiplier_per_level: float = 1.10 

func _ready():
    room_name = "Apiary"
    base_cost = 60
    cost_multiplier = 1.8
    super._ready()

func apply_upgrade_effect():
    GlobalUpgrades.add_speed_multiplier(speed_multiplier_per_level)

func revert_all_effects():
    for i in range(level):
        GlobalUpgrades.remove_speed_multiplier(speed_multiplier_per_level)

func get_effect_description() -> String:
    return "Increases bee speed\n(Total Multiplier: x%.2f)" % GlobalUpgrades.bee_speed_multiplier
