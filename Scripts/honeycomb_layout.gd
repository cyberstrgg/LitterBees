# honeycomb_layout.gd
extends Control

## The hexagonal slot scene to instance.
@export var slot_scene: PackedScene
## The number of columns in the honeycomb grid.
@export var columns: int = 5
## The number of rows in the honeycomb grid.
@export var rows: int = 4


func _ready():
    generate_layout()

func generate_layout():
    if not slot_scene:
        print_rich("[color=red]ERROR: Slot Scene is not assigned in HoneycombLayout.[/color]")
        return

    # Clear any existing children before generating new ones.
    for child in get_children():
        child.queue_free()

    # Get the size of a single hexagon slot from its scene properties.
    # This assumes the root node has a custom_minimum_size set.
    var slot_instance_for_size = slot_scene.instantiate()
    var hex_size = slot_instance_for_size.custom_minimum_size
    slot_instance_for_size.queue_free() # We don't need this instance anymore.

    var x_spacing = hex_size.x
    var y_spacing = hex_size.y * 0.75 # Rows are packed tighter vertically.

    for r in range(rows):
        for c in range(columns):
            var slot = slot_scene.instantiate()
            var x_pos = c * x_spacing
            var y_pos = r * y_spacing

            # This is the key to the honeycomb layout:
            # Offset every odd-numbered row to the right by half a hexagon's width.
            if r % 2 != 0:
                x_pos += x_spacing / 2.0
            
            slot.position = Vector2(x_pos, y_pos)
            add_child(slot)
