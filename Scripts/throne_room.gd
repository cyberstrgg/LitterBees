
extends PanelContainer

# This script is a placeholder for any unique logic the throne room might have.
# For example, you might want to prevent clicks or display queen-related stats.

func _ready():
    # You can add specific initialization logic for the throne room here.
    pass

# Override the input function to prevent it from being treated like a normal buildable slot.
func _gui_input(event: InputEvent):
    if event is InputEventMouseButton and event.is_pressed():
        print("The Queen's Throne Room. Cannot be modified.")
        # Mark the input as handled so other nodes don't process it.
        get_viewport().set_input_as_handled()
