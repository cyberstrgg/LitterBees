extends Node

# --- Scrap Variable ---
var scrap_total: int = 0

## Bee Stats
var bee_damage: int = 1
var bee_speed_multiplier: float = 1.0
var hive_recovery_cooldown: float = 1.0 # Default 1-second cooldown


## --- Upgrade Functions ---
func upgrade_damage():
    bee_damage += 1
    print("Bee damage upgraded to: ", bee_damage)

func upgrade_speed():
    bee_speed_multiplier += 0.1
    print("Bee speed multiplier is now: ", bee_speed_multiplier)

func upgrade_recovery():
    hive_recovery_cooldown = max(0.0, hive_recovery_cooldown - 0.2)
    print("Hive recovery cooldown is now: ", hive_recovery_cooldown)
