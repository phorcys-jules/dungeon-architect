extends SceneTree

const MainScene := preload("res://scenes/main.tscn")
const TRAP_ASSET_ROOT := "res://assets/sprites/traps/"


func _init() -> void:
    var game = MainScene.instantiate()
    for trap_id in TrapCatalog.ORDER:
        var path := TRAP_ASSET_ROOT + String(trap_id) + ".png"
        assert(ResourceLoader.exists(path), "Missing trap asset: %s" % path)
        var texture := load(path) as Texture2D
        assert(texture != null)
        assert(texture.get_size() == Vector2(64, 64))
        assert(game.TRAP_TEXTURES.has(trap_id))
    game.free()
    print("trap_assets_test: OK")
    quit()
