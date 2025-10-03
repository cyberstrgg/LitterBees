extends PanelContainer

@export var polygon_2d: Polygon2D

func _ready():
    # Draw the hexagon background
    var size = self.custom_minimum_size
    var center = size / 2.0
    var hexagon_points = PackedVector2Array()
    
    for i in range(6):
        var angle_deg = 60 * i + 30 # Pointy-top
        var angle_rad = deg_to_rad(angle_deg)
        hexagon_points.append(center + Vector2(center.x * cos(angle_rad), center.y * sin(angle_rad)))
    
    if polygon_2d:
        polygon_2d.polygon = hexagon_points


func _gui_input(event: InputEvent):
    if event is InputEventMouseButton and event.is_pressed():
        print("The Queen's Throne Room. Cannot be modified.")
        get_viewport().set_input_as_handled()
