class_name MonsterOrders
extends RefCounted

# Orders: guard, intercept, funnel, retreat, protect_trap

func resolve_order(monster_profile: Dictionary, order: String, context: Dictionary) -> Dictionary:
	# returns {accepted: bool, reason: String}
	if order == "guard":
		return {"accepted": true, "reason": "on_guard"}
	if order == "retreat" and monster_profile.get("bravery",1) < 0.3:
		return {"accepted": true, "reason": "cowardice"}
	return {"accepted": false, "reason": "ignored"}
