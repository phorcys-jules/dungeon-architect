class_name DailyChallenge
extends Node

# Deterministic daily challenge helper. Mirrors tools/daily_challenge.py

static func make_seed_from_date(date_text: String) -> int:
	var parts := date_text.split("-")
	if parts.size() != 3:
		return 0
	var year := int(parts[0])
	var month := int(parts[1])
	var day := int(parts[2])
	return year * 10000 + month * 100 + day

static func make_daily_config_from_date(date_text: String) -> Dictionary:
	var seed := make_seed_from_date(date_text)
	var mutator := "double_rewards" if seed % 2 == 0 else "tougher_monsters"
	return {
		"date": date_text,
		"seed": seed,
		"rules": {
			"no_permanent_rewards": true,
			"mutator": mutator,
		},
	}

static func get_current_from_file(path: String = "data/daily/current.json") -> Dictionary:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {}
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	file.close()
	if typeof(parsed) != TYPE_DICTIONARY:
		return {}
	return parsed as Dictionary

func _ready() -> void:
	pass
