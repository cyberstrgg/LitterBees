# GlobalUpgrades.gd
extends Node

# --- Scrap Variable ---
var scrap_total: int = 50
const NEW_SLOT_COST: int = 75 # Cost to unlock a new empty slot

# --- Room Grid State ---
# Dictionary mapping Vector2i (axial coordinates) to room type (String)
var grid_layout: Dictionary = {
    Vector2i(0, 0): "throne",
    Vector2i(1, 0): "empty",
    Vector2i(-1, 0): "empty",
    Vector2i(0, 1): "empty",
    Vector2i(0, -1): "empty",
    Vector2i(1, -1): "empty",
    Vector2i(-1, 1): "empty"
}


# --- Base Stats ---
const BASE_BEE_DAMAGE: int = 1
const BASE_BEE_SPEED: float = 1.0
const BASE_HIVE_RECOVERY: float = 1.0

# --- Room Bonus Values ---
const DAMAGE_ROOM_BONUS: int = 1
const SPEED_ROOM_MULTIPLIER: float = 1.25  # 25% increase
const RECOVERY_ROOM_MULTIPLIER: float = 0.8 # 20% faster

## Bee Stats (These will be recalculated)
var bee_damage: int = BASE_BEE_DAMAGE
var bee_speed_multiplier: float = BASE_BEE_SPEED
var hive_recovery_cooldown: float = BASE_HIVE_RECOVERY


# --- NEW: Central function to calculate all stats ---
func recalculate_all_stats():
    # 1. Reset all stats to their base values
    bee_damage = BASE_BEE_DAMAGE
    bee_speed_multiplier = BASE_BEE_SPEED
    hive_recovery_cooldown = BASE_HIVE_RECOVERY
    
    # 2. Loop through the grid and apply bonuses
    for room_type in grid_layout.values(): # Iterate over dictionary values
        match room_type:
            "damage":
                bee_damage += DAMAGE_ROOM_BONUS
            "speed":
                bee_speed_multiplier *= SPEED_ROOM_MULTIPLIER
            "recovery":
                hive_recovery_cooldown *= RECOVERY_ROOM_MULTIPLIER
                
    print("Stats Recalculated: Damage=%d, Speed=x%.2f, Recovery=%.2fs" % [bee_damage, bee_speed_multiplier, hive_recovery_cooldown])
