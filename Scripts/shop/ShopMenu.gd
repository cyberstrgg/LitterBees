# Scripts/Shop/ShopMenu.gd
extends CanvasLayer

signal bee_purchased(bee_type_id)

const BeeCardScene = preload("res://Scenes/Shop/BeeCard.tscn")

@onready var card_container: HBoxContainer = $CenterContainer/PanelContainer/VBoxContainer/ScrollContainer/CardContainer
@onready var scrap_label: Label = $CenterContainer/PanelContainer/VBoxContainer/ScrapLabel
@onready var close_button: Button = $CenterContainer/PanelContainer/VBoxContainer/CloseButton

func _ready():
    close_button.pressed.connect(queue_free)
    populate_shop()
    update_ui()

func populate_shop():
    for child in card_container.get_children():
        child.queue_free()

    for bee_type_id in GlobalUpgrades.bee_data:
        var card = BeeCardScene.instantiate()
        card_container.add_child(card)
        card.setup(bee_type_id)
        card.buy_bee_requested.connect(_on_buy_bee_requested)

func _on_buy_bee_requested(bee_type_id: String):
    var cost = GlobalUpgrades.get_bee_cost(bee_type_id)
    
    if GlobalUpgrades.scrap_total >= cost:
        GlobalUpgrades.scrap_total -= cost
        
        if GlobalUpgrades.owned_bees.has(bee_type_id):
            GlobalUpgrades.owned_bees[bee_type_id] += 1
        else:
            GlobalUpgrades.owned_bees[bee_type_id] = 1
        
        emit_signal("bee_purchased", bee_type_id)
        update_ui()

func update_ui():
    scrap_label.text = "Scrap: %d" % GlobalUpgrades.scrap_total
    
    for card in card_container.get_children():
        if card.has_method("update_display"):
            card.update_display()
