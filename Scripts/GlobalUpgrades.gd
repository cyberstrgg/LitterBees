# GlobalUpgrades.gd
extends Node

# --- Scrap Variable ---
var scrap_total: int = 0

## Bee Stats
var bee_damage: int = 1
var bee_speed_multiplier: float = 1.0
var hive_recovery_cooldown: float = 1.0

## --- Upgrade / Downgrade Functions ---
func add_damage_bonus(amount: int):
    bee_damage += amount
    print("Damage bonus of %d applied. Total Damage: %d" % [amount, bee_damage])

func remove_damage_bonus(amount: int):
    bee_damage = max(1, bee_damage - amount)
    print("Damage bonus of %d removed. Total Damage: %d" % [amount, bee_damage])

func add_speed_multiplier(multiplier: float):
    bee_speed_multiplier *= multiplier
    print("Speed multiplier of x%.2f applied. Total Multiplier: %.2f" % [multiplier, bee_speed_multiplier])

func remove_speed_multiplier(multiplier: float):
    if multiplier != 0:
        bee_speed_multiplier /= multiplier
    print("Speed multiplier of x%.2f removed. Total Multiplier: %.2f" % [multiplier, bee_speed_multiplier])

func add_recovery_multiplier(multiplier: float):
    hive_recovery_cooldown *= multiplier
    print("Recovery multiplier of x%.2f applied. Total Cooldown: %.2f" % [multiplier, hive_recovery_cooldown])

func remove_recovery_multiplier(multiplier: float):
    if multiplier != 0:
        hive_recovery_cooldown /= multiplier
    print("Recovery multiplier of x%.2f removed. Total Cooldown: %.2f" % [multiplier, hive_recovery_cooldown])
