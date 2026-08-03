extends SceneTree

const TILE_ROOT := "res://assets/sprites/biomes/"


func _init() -> void:
	for biome_id in BiomeCatalog.new().all_ids():
		for kind in ["floor", "wall"]:
			var path: String = TILE_ROOT + biome_id + "_" + String(kind) + ".png"
			assert(ResourceLoader.exists(path), "Missing biome tile: %s" % path)
			var texture := load(path) as Texture2D
			assert(texture != null)
			assert(texture.get_size() == Vector2(128, 128))
	print("biome_tile_assets_test: OK")
	quit()
