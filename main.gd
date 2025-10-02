extends Node2D

@export var upgrades_menu_scene: PackedScene
@export var trash_scene: PackedScene
@export var bee_scene: PackedScene
@export var initial_trash_node: Node2D
@export var hive_node: Node2D
@export var camera_node: Camera2D
@export var score_label: Label
@export var buy_bee_button: Button

# --- Gameplay Tweak Variables ---
@export var hive_exclusion_radius: float = 150.0
@export var spawn_padding: float = 64.0

# --- Purchase Formula Variables ---
@export var base_bee_cost: int = 15
@export var bee_price_multiplier: float = 1.15
var next_bee_cost: int = 0

# --- scrap_total is now in GlobalUpgrades.gd ---
# var scrap_total: int = 0 <-- DELETE THIS LINE

func _ready():
    if is_instance_valid(initial_trash_node):
        initial_trash_node.trash_destroyed.connect(on_trash_destroyed)
    
    update_score_label() # This will now pull from the global script

    await get_tree().process_frame
    var initial_bees = get_tree().get_nodes_in_group("bees")
    for bee in initial_bees:
        connect_bee_signals(bee)
    
    get_tree().call_group("bees", "reassign_trash_target")

func connect_bee_signals(bee_node):
    if not bee_node.is_connected("scrap_delivered", on_scrap_delivered):
        bee_node.scrap_delivered.connect(on_scrap_delivered)

func on_scrap_delivered():
    # --- Modify this line ---
    GlobalUpgrades.scrap_total += 1
    update_score_label()

func update_score_label():
    if is_instance_valid(score_label):
        # --- Modify this line ---
        score_label.text = "Scrap: %d" % GlobalUpgrades.scrap_total
    update_bee_cost()

func update_bee_cost():
    var bee_count = get_tree().get_nodes_in_group("bees").size()
    next_bee_cost = int(base_bee_cost * pow(bee_price_multiplier, bee_count))
    
    if is_instance_valid(buy_bee_button):
        buy_bee_button.text = "Buy Bee (%d Scrap)" % next_bee_cost
        # --- Modify this line ---
        buy_bee_button.disabled = GlobalUpgrades.scrap_total < next_bee_cost

func spawn_bee():
    if not bee_scene: return

    var new_bee = bee_scene.instantiate()
    new_bee.hive_node = hive_node
    
    connect_bee_signals(new_bee)
    
    new_bee.global_position = hive_node.global_position
    add_child(new_bee)
    
    new_bee.reassign_trash_target()

func on_trash_destroyed(_old_position: Vector2, new_health: int):
    await get_tree().create_timer(0.2).timeout
    
    var new_trash = trash_scene.instantiate()
    new_trash.health = new_health
    
    var view_size = get_viewport().get_visible_rect().size
    var spawn_pos = Vector2.ZERO
    camera_node.add_child(new_trash)
    while true:
        var half_size = view_size / 2.0
        spawn_pos.x = randf_range(-half_size.x + spawn_padding, half_size.x - spawn_padding)
        spawn_pos.y = randf_range(-half_size.y + spawn_padding, half_size.y - spawn_padding)
        new_trash.position = spawn_pos
        if new_trash.global_position.distance_to(hive_node.global_position) > hive_exclusion_radius:
            break
    new_trash.reparent(self)

    new_trash.trash_destroyed.connect(on_trash_destroyed)
    
    get_tree().call_group("bees", "reassign_trash_target")

func _on_button_pressed():
    # --- Modify this line ---
    if GlobalUpgrades.scrap_total >= next_bee_cost:
        # --- And this line ---
        GlobalUpgrades.scrap_total -= next_bee_cost
        spawn_bee()
        update_score_label()

func _on_upgrades_button_pressed():
    # Check if the menu is already open to prevent opening multiple instances
    if get_tree().get_first_node_in_group("upgrades_menu"):
        return

    # Create an instance of the menu scene
    var menu = upgrades_menu_scene.instantiate()
    
    # Add the menu to a group so we can check if it exists
    menu.add_to_group("upgrades_menu")
    
    # Add the menu to the scene tree, making it visible
    add_child(menu)
