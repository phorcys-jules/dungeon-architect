class_name DailyChallenge
extends RefCounted

# Produces a deterministic daily challenge config based on date
func config_for_date(date_str: String) -> Dictionary:
	# date_str: YYYY-MM-DD
	var seed := 0
	for c in date_str:
		seed += int(ord(c))
	var modifiers := []
	if seed % 2 == 0:
		modifiers.append("no_traps")
	if seed % 3 == 0:
		modifiers.append("double_hp")
	return {"seed": seed, "modifiers": modifiers, "date": date_str}

func today_config() -> Dictionary:
	var d := OS.get_date()
	var date_str := "%d-%02d-%02d" % [d.year, d.month, d.day]
	return config_for_date(date_str)
