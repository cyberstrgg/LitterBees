# speed_room.gd
extends "res://Scripts/UpgradeRooms/base_upgrade_room.gd"

# Note: The 'speed_multiplier_per_level' variable is no longer used here.
# The actual value is now stored as a constant inside GlobalUpgrades.gd.

func _ready():
    room_name = "Apiary"
    base_cost = 60
    cost_multiplier = 1.8
    super._ready()

# This function should be deleted. The base script must not call it.
# func apply_upgrade_effect():
    # GlobalUpgrades.add_speed_multiplier(speed_multiplier_per_level) # This function was removed

# This function should be deleted.
# func revert_all_effects():
    # for i in range(level):
        # GlobalUpgrades.remove_speed_multiplier(speed_multiplier_per_level) # This function was removed

func get_effect_description() -> String:
    # This function is still great for UI, as it reads the up-to-date global value.
    return "Increases bee speed\n(Total Multiplier: x%.2f)" % GlobalUpgrades.bee_speed_multiplier
