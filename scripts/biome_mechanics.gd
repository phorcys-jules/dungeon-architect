class_name BiomeMechanics
extends RefCounted

# Minimal mechanics placeholder per biome
func get_mechanics(biome_name: String) -> Array:
	match biome_name:
		"crypt":
			return ["tomb_activate","cursed_zone"]
		"mine":
			return ["collapse","rails"]
		"castle":
			return ["portcullis","balcony"]
		"sewers":
			return ["valve","current"]
		_:
			return []
