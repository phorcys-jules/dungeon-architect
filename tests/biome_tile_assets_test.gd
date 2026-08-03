extends SceneTree

const DungeonScene := preload("res://scenes/main.tscn")
const TILE_ROOT := "res://assets/sprites/biomes/"


func _init() -> void:
    var dungeon = DungeonScene.instantiate()
    for biome_id in BiomeCatalog.new().all_ids():
        assert(dungeon.BIOME_TILE_TEXTURES.has(biome_id))
        for kind in ["floor", "wall"]:
            var path: String = TILE_ROOT + biome_id + "_" + String(kind) + ".png"
            assert(ResourceLoader.exists(path), "Missing biome tile: %s" % path)
            var texture := load(path) as Texture2D
            assert(texture != null)
            assert(texture.get_size() == Vector2(128, 128))
    dungeon.free()
    print("biome_tile_assets_test: OK")
    quit()
