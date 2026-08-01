extends SceneTree

const MAIN_SCENE := "res://scenes/main.tscn"

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var packed_scene := load(MAIN_SCENE) as PackedScene
    if packed_scene == null:
        push_error("Impossible de charger %s" % MAIN_SCENE)
        quit(1)
        return

    var instance := packed_scene.instantiate()
    if instance == null:
        push_error("Impossible d'instancier la scène principale")
        quit(1)
        return

    root.add_child(instance)
    await process_frame
    await process_frame

    print("Smoke test réussi : la scène principale se charge et démarre.")
    quit(0)
