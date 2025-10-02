# base_upgrade_room.gd
extends PanelContainer

signal room_demolished(refund_amount, room_instance)

@export var room_name: String = "Upgrade Room"
@export_group("Cost Scaling")
@export var base_cost: int = 50
@export var cost_multiplier: float = 1.5
@export_group("Effect Scaling")
@export var base_effect_value: float = 1.0 # Can be damage, multiplier, etc.
@export var effect_increment: float = 1.0

# --- State ---
var level: int = 1
var total_scrap_invested: int = 0

# --- Node References ---
@onready var name_label: Label = $MarginContainer/VBoxContainer/NameLabel
@onready var level_label: Label = $MarginContainer/VBoxContainer/LevelLabel
@onready var effect_label: Label = $MarginContainer/VBoxContainer/EffectLabel
@onready var upgrade_button: Button = $MarginContainer/VBoxContainer/UpgradeButton
@onready var demolish_button: Button = $MarginContainer/VBoxContainer/DemolishButton

func _ready():
    # Connect button signals
    upgrade_button.pressed.connect(_on_upgrade_button_pressed)
    demolish_button.pressed.connect(_on_demolish_button_pressed)
    
    # Initial setup
    name_label.text = room_name
    total_scrap_invested = base_cost
    apply_upgrade_effect()
    update_ui()

func update_ui():
    level_label.text = "Level: %d" % level
    effect_label.text = get_effect_description()
    
    var next_cost = calculate_upgrade_cost()
    upgrade_button.text = "Upgrade (%d Scrap)" % next_cost
    upgrade_button.disabled = GlobalUpgrades.scrap_total < next_cost

func calculate_upgrade_cost() -> int:
    return int(base_cost * pow(cost_multiplier, level))

func get_refund_amount() -> int:
    return int(total_scrap_invested * 0.5) # Refund 50% of scrap spent

func _on_upgrade_button_pressed():
    var cost = calculate_upgrade_cost()
    if GlobalUpgrades.scrap_total >= cost:
        GlobalUpgrades.scrap_total -= cost
        total_scrap_invested += cost
        level += 1
        apply_upgrade_effect()
        update_ui()

func _on_demolish_button_pressed():
    revert_all_effects()
    var refund = get_refund_amount()
    emit_signal("room_demolished", refund, self)
    queue_free()

# --- Virtual functions for child scripts to implement ---
func apply_upgrade_effect():
    # This will be overridden by child scripts (DamageRoom, SpeedRoom, etc.)
    pass

func revert_all_effects():
    # This will be overridden by child scripts
    pass

func get_effect_description() -> String:
    # This will be overridden by child scripts
    return "Effect TBD"
