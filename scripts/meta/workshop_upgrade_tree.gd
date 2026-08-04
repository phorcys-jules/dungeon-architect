class_name WorkshopUpgradeTree
extends RefCounted

const NODES := {
	"contracts_extra_offer": {"station": "contracts", "level": 1, "cost": {"payment": 120, "blueprints": 5}, "effects": {"contract_choices": 1}},
	"contracts_negotiator": {"station": "contracts", "level": 2, "requires": ["contracts_extra_offer"], "cost": {"payment": 220, "reputation": 8}, "effects": {"payment_multiplier": 0.10}},
	"blueprints_secret_passages": {"station": "blueprints", "level": 1, "cost": {"payment": 140, "blueprints": 8}, "effects": {"unlock": "secret_passages"}},
	"blueprints_biome_adaptation": {"station": "blueprints", "level": 2, "requires": ["blueprints_secret_passages"], "cost": {"payment": 260, "materials": 70}, "effects": {"biome_penalty_reduction": 0.20}},
	"forge_reinforced_traps": {"station": "forge", "level": 1, "cost": {"payment": 150, "materials": 45}, "effects": {"trap_durability_multiplier": 1.15}},
	"forge_salvage": {"station": "forge", "level": 2, "requires": ["forge_reinforced_traps"], "cost": {"payment": 240, "materials": 80}, "effects": {"refund_multiplier": 0.15}},
	"laboratory_second_trait": {"station": "laboratory", "level": 1, "cost": {"payment": 170, "materials": 50}, "effects": {"monster_trait_slots": 1}},
	"laboratory_mutation_control": {"station": "laboratory", "level": 2, "requires": ["laboratory_second_trait"], "cost": {"payment": 280, "blueprints": 12}, "effects": {"mutation_rerolls": 1}},
	"archives_forecast": {"station": "archives", "level": 1, "cost": {"payment": 100, "reputation": 5}, "effects": {"reveal_adventurer_trait": 1}},
	"trophies_prestige": {"station": "trophies", "level": 1, "cost": {"payment": 200, "reputation": 12}, "effects": {"reputation_multiplier": 0.10}},
}

var unlocked: Dictionary = {}

func available_nodes(workshop: WorkshopHub) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for node_id in NODES:
		var node: Dictionary = NODES[node_id]
		if int(workshop.module_levels.get(node.station, 0)) < int(node.level):
			continue
		if not _requirements_met(node):
			continue
		var view := node.duplicate(true)
		view["id"] = node_id
		view["unlocked"] = bool(unlocked.get(node_id, false))
		view["affordable"] = _can_afford(workshop.resources, node.cost)
		result.append(view)
	return result

func unlock(node_id: String, workshop: WorkshopHub) -> Dictionary:
	if not NODES.has(node_id) or bool(unlocked.get(node_id, false)):
		return {"ok": false, "reason": "invalid"}
	var node: Dictionary = NODES[node_id]
	if int(workshop.module_levels.get(node.station, 0)) < int(node.level) or not _requirements_met(node):
		return {"ok": false, "reason": "requirements"}
	if not _can_afford(workshop.resources, node.cost):
		return {"ok": false, "reason": "resources"}
	for resource_id in node.cost:
		workshop.resources[resource_id] = int(workshop.resources.get(resource_id, 0)) - int(node.cost[resource_id])
	unlocked[node_id] = true
	return {"ok": true, "node_id": node_id, "effects": node.effects.duplicate(true)}

func combined_effects() -> Dictionary:
	var effects: Dictionary = {}
	for node_id in unlocked:
		if not bool(unlocked[node_id]):
			continue
		for effect_id in NODES[node_id].effects:
			var value = NODES[node_id].effects[effect_id]
			if value is float or value is int:
				effects[effect_id] = float(effects.get(effect_id, 0.0)) + float(value)
			else:
				effects[effect_id] = value
	return effects

func to_dict() -> Dictionary:
	return {"unlocked": unlocked.duplicate(true)}

func from_dict(data: Dictionary) -> void:
	unlocked.clear()
	var saved: Dictionary = data.get("unlocked", {})
	for node_id in saved:
		if NODES.has(node_id) and bool(saved[node_id]):
			unlocked[node_id] = true

func _requirements_met(node: Dictionary) -> bool:
	for required_id in node.get("requires", []):
		if not bool(unlocked.get(String(required_id), false)):
			return false
	return true

func _can_afford(resources: Dictionary, cost: Dictionary) -> bool:
	for resource_id in cost:
		if int(resources.get(resource_id, 0)) < int(cost[resource_id]):
			return false
	return true
