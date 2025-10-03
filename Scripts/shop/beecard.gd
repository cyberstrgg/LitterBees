# Scripts/Shop/BeeCard.gd
extends PanelContainer

signal buy_bee_requested(bee_type_id)

@onready var name_label: Label = $MarginContainer/VBoxContainer/NameLabel
@onready var bee_texture: TextureRect = $MarginContainer/VBoxContainer/BeeTexture
@onready var owned_label: Label = $MarginContainer/VBoxContainer/OwnedLabel
@onready var buy_button: Button = $MarginContainer/VBoxContainer/BuyButton

var bee_type_id: String

func _ready():
    buy_button.pressed.connect(func(): emit_signal("buy_bee_requested", bee_type_id))

func setup(type_id: String):
    self.bee_type_id = type_id
    
    if not GlobalUpgrades.bee_data.has(type_id):
        print("Error: Bee type '%s' not found in GlobalUpgrades." % type_id)
        queue_free()
        return
    
    var data = GlobalUpgrades.bee_data[type_id]
    
    name_label.text = data.name
    if data.has("texture_path") and not data.texture_path.is_empty():
        bee_texture.texture = load(data.texture_path)
    
    update_display()

func update_display():
    if not GlobalUpgrades.bee_data.has(bee_type_id):
        return

    var owned_count = GlobalUpgrades.owned_bees.get(bee_type_id, 0)
    owned_label.text = "Owned: %d" % owned_count
    
    var cost = GlobalUpgrades.get_bee_cost(bee_type_id)
    buy_button.text = "Buy (%d Scrap)" % cost
    buy_button.disabled = GlobalUpgrades.scrap_total < cost
