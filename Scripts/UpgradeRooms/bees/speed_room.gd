# speed_room.gd
extends "res://Scripts/UpgradeRooms/base_upgrade_room.gd"

func _ready():
    room_name = "Apiary"
    base_cost = 60
    cost_multiplier = 1.8
    super._ready()
    # Set a placeholder color for the speed room
    polygon_2d.color = Color(0.2, 0.6, 0.2)

func get_effect_description() -> String:
    # This function is still great for UI, as it reads the up-to-date global value.
    return "Increases bee speed\n(Total Multiplier: x%.2f)" % GlobalUpgrades.bee_speed_multiplier
