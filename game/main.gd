extends Node3D

@export var sandbox: PackedScene
@export var main_menu: PackedScene
@export var pause_menu: PackedScene

# Cache a reference to the UI container node for reuse.
var ui_node: Node

func _ready():
    ui_node = $UI
    # Instantiate and display the main menu.
    var main_menu_instance = main_menu.instantiate()
    main_menu_instance.init_sandbox.connect(_on_init_sandbox)
    ui_node.call_deferred("add_child", main_menu_instance)

# Signal handler for when the main menu triggers the start of the sandbox.
func _on_init_sandbox():
    # Instantiate the sandbox and pause menu scenes.
    var sandbox_instance = sandbox.instantiate()
    var pause_menu_instance = pause_menu.instantiate()
    
    # Connect sandbox quit signal to our handler.
    sandbox_instance.quit.connect(_on_quit_sandbox)
    
    # Initialize the sandbox scene with callbacks from the pause menu.
    sandbox_instance.init(
        pause_menu_instance.resume_pressed,
        pause_menu_instance.restart_pressed,
        pause_menu_instance.quit_pressed
    )
    # Initialize the pause menu with sandbox pause/unpause functions.
    pause_menu_instance.init(
        sandbox_instance.pause,
        sandbox_instance.unpause
    )
    
    # Safely remove the main menu.
    if ui_node.has_node("MainMenu"):
        ui_node/MainMenu.queue_free()
    # Add the new scenes to the tree using deferred calls.
    call_deferred("add_child", sandbox_instance)
    ui_node.call_deferred("add_child", pause_menu_instance)

# Signal handler for when the sandbox quits.
func _on_quit_sandbox():
    # Remove the pause menu and sandbox from the UI.
    if ui_node.has_node("PauseMenu"):
        ui_node/PauseMenu.queue_free()
    if has_node("Sandbox"):
        $Sandbox.queue_free()
    
    # Re-instantiate the main menu.
    var main_menu_instance = main_menu.instantiate()
    main_menu_instance.init_sandbox.connect(_on_init_sandbox)
    ui_node.call_deferred("add_child", main_menu_instance)
