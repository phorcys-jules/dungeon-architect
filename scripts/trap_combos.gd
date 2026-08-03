class_name TrapCombos
extends RefCounted

# Data-driven combo recipes with discovery tracking and cooldown window
var recipes := {
	"poix+feu": {"name":"Brûlure infectieuse","effects":["burn","poison"]},
	"givre+pointes": {"name":"Gel tranchant","effects":["slow","bleed"]}
}
var discovered := {}
var last_trigger_time := {}
var trigger_window := 1.0 # seconds

func resolve_combo(a: String, b: String, now: float = 0.0) -> Dictionary:
	var key := "%s+%s" % [a,b]
	if not recipes.has(key):
		key = "%s+%s" % [b,a]
	if not recipes.has(key):
		return {}
	# cooldown: avoid double trigger within window
	if last_trigger_time.get(key, -9999.0) + trigger_window > now:
		return {}
	last_trigger_time[key] = now
	discovered[key] = true
	return recipes[key]

func is_discovered(a: String, b: String) -> bool:
	var key := "%s+%s" % [a,b]
	if not recipes.has(key):
		key = "%s+%s" % [b,a]
	return discovered.get(key, false)
