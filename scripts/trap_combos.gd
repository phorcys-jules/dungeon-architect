class_name TrapCombos
extends RefCounted

# Data-driven combo recipes
var recipes := {
	"poix+feu": {"name":"Brûlure infectieuse","effects":["burn","poison"]},
	"givre+pointes": {"name":"Gel tranchant","effects":["slow","bleed"]}
}

func resolve_combo(a: String, b: String) -> Dictionary:
	var key := "%s+%s" % [a,b]
	if recipes.has(key):
		return recipes[key]
	key = "%s+%s" % [b,a]
	return recipes.get(key, {})
