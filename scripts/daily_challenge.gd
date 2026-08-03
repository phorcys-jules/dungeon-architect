class_name DailyChallenge
extends Node

# Deterministic daily challenge helper. Mirrors tools/daily_challenge.py

static func make_seed_from_date(d: String) -> int:
	# d is ISO date string "YYYY-MM-DD"
	var parts = d.split("-")
	if parts.size() != 3:
		return 0
	var y = int(parts[0])
	var m = int(parts[1])
	var day = int(parts[2])
	return y * 10000 + m * 100 + day

static func make_daily_config_from_date(d: String) -> Dictionary:
	var seed = make_seed_from_date(d)
	var mutator = (seed % 2 == 0) ? "double_rewards" : "tougher_monsters"
	return {
		"date": d,
		"seed": seed,
		"rules": {
			"no_permanent_rewards": true,
			"mutator": mutator
		}
	}

static func get_current_from_file(path: String = "data/daily/current.json") -> Dictionary:
	var f = FileAccess.open(path, FileAccess.READ)
	if not f:
		return {}
	var txt = f.get_as_text()
	f.close()
	var err, parsed = JSON.parse_string(txt)
	if err != OK:
		return {}
	return parsed

func _ready() -> void:
	# noop
	pass
