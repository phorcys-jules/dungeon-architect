class_name DebriefManager
extends RefCounted

# Produces lightweight spatial debrief data (heatmap + key moments)
# replay: { positions: [ {pos: Vector2, time: float} ], events: [ {type:String, time:float, data:Dictionary} ] }
func analyze(replay: Dictionary) -> Dictionary:
	var positions = replay.get("positions", [])
	var events = replay.get("events", [])
	# Heatmap: map string "x,y" -> count
	var heatmap := {}
	for p in positions:
		var k := "%d,%d" % [int(p.pos.x), int(p.pos.y)]
		heatmap[k] = heatmap.get(k, 0) + 1
	# Key moments: first damage, highest damage event, end
	var first_damage := null
	var max_damage := null
	var max_damage_val := -1
	for e in events:
		if e.get("type", "") == "damage":
			if first_damage == null:
				first_damage = e
			var val := int(e.get("data", {}).get("amount", 0))
			if val > max_damage_val:
				max_damage_val = val
				max_damage = e
	var summary := {
		"samples": positions.size(),
		"heatmap_bins": heatmap.size(),
		"first_damage": first_damage,
		"max_damage": max_damage,
		"events_count": events.size(),
	}
	return {"summary": summary, "heatmap": heatmap}
