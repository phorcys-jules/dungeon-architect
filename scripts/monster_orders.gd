class_name MonsterOrders
extends RefCounted

# Orders: guard, intercept, funnel, retreat, protect_trap
# Returns {accepted: bool, reason: String, priority: int}

func resolve_order(monster_profile: Dictionary, order: String, context: Dictionary) -> Dictionary:
	var bravery := float(monster_profile.get("bravery", 0.5))
	var panic := float(monster_profile.get("panic", 0.0))
	var priority: int = int(context.get("priority", 1))
	# High panic or low bravery tends to ignore risky orders
	if panic > 0.75 and order != "retreat":
		return {"accepted": false, "reason": "panicked", "priority": 0}
	if order == "guard":
		# prefer guard if stable and not panicked
		if panic < 0.5:
			return {"accepted": true, "reason": "guarding", "priority": priority}
		return {"accepted": false, "reason": "refused_panicked", "priority": 0}
	if order == "retreat":
		if bravery < 0.4 or panic > 0.6:
			return {"accepted": true, "reason": "retreating", "priority": priority}
		return {"accepted": false, "reason": "stubborn", "priority": 0}
	if order == "intercept":
		# accept intercept if not busy and priority high
		if bool(context.get("busy", false)):
			return {"accepted": false, "reason": "busy", "priority": 0}
		if priority >= 2:
			return {"accepted": true, "reason": "intercepting", "priority": priority}
		return {"accepted": false, "reason": "low_priority", "priority": 0}
	# fallback
	return {"accepted": false, "reason": "unknown_order", "priority": 0}
