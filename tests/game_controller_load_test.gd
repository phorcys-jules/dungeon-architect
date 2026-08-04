extends SceneTree

func _init() -> void:
    var controller_script := ResourceLoader.load("res://scripts/game_controller.gd", "Script", ResourceLoader.CACHE_MODE_IGNORE)
    if controller_script == null:
        push_error("game_controller.gd could not be loaded")
        quit(1)
        return
    var controller := Node2D.new()
    controller.set_script(controller_script)
    assert(controller.get_script() == controller_script)
    controller.free()
    print("game controller load test passed")
    quit(0)
