extends SceneTree

const GameControllerScript := preload("res://scripts/game_controller.gd")

func _init() -> void:
    var controller := Node2D.new()
    controller.set_script(GameControllerScript)
    assert(controller.get_script() == GameControllerScript)
    controller.free()
    print("game controller load test passed")
    quit(0)
