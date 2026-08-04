class_name MonsterContractSystem
extends RefCounted

const CLIENTS := {
	"lich": {
		"name": "Maître Ossuaire",
		"title": "Liche conservatrice",
		"preferred_biomes": ["crypt", "castle"],
		"brief": "Protéger un phylactère sans laisser les aventuriers atteindre la salle centrale.",
	},
	"dragon": {
		"name": "Dame Cendrecroc",
		"title": "Dragonne collectionneuse",
		"preferred_biomes": ["mine", "castle"],
		"brief": "Défendre un trésor exceptionnel et punir les pillards.",
	},
	"spider_queen": {
		"name": "Reine Velours-Noir",
		"title": "Souveraine arachnéenne",
		"preferred_biomes": ["sewer", "crypt"],
		"brief": "Capturer les intrus vivants pour agrandir la couvée.",
	},
	"vampire": {
		"name": "Comte Sanguinor",
		"title": "Noble vampire",
		"preferred_biomes": ["castle", "crypt"],
		"brief": "Concevoir un donjon élégant, efficace et peu destructif.",
	},
}

const CONTRACT_TEMPLATES := {
	"protect_relic": {
		"objective": "protect_target",
		"base_payment": 120,
		"base_reputation": 8,
		"clauses": [
			{"id": "target_untouched", "weight": 0.45},
			{"id": "minimum_captures", "target": 3, "weight": 0.25},
			{"id": "budget_respected", "weight": 0.30},
		],
	},
	"capture_alive": {
		"objective": "capture_alive",
		"base_payment": 135,
		"base_reputation": 10,
		"clauses": [
			{"id": "minimum_captures", "target": 5, "weight": 0.50},
			{"id": "low_lethal_damage", "max": 0.35, "weight": 0.30},
			{"id": "family_required", "family": "beast", "weight": 0.20},
		],
	},
	"protect_treasure": {
		"objective": "protect_treasure",
		"base_payment": 150,
		"base_reputation": 11,
		"clauses": [
			{"id": "treasure_retained", "min": 0.85, "weight": 0.50},
			{"id": "elite_defeated", "target": 1, "weight": 0.20},
			{"id": "trap_damage", "min": 100, "weight": 0.30},
		],
	},
	"elegant_defense": {
		"objective": "defend_with_style",
		"base_payment": 145,
		"base_reputation": 12,
		"clauses": [
			{"id": "wall_loss_limit", "max": 2, "weight": 0.30},
			{"id": "room_variety", "target": 4, "weight": 0.35},
			{"id": "minimum_captures", "target": 3, "weight": 0.35},
		],
	},
}

var active_contract: Dictionary = {}
var completed_contracts: Array[String] = []

func generate_contract(seed: int, reputation: int = 0) -> Dictionary:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed
	var client_ids: Array[String] = []
	client_ids.assign(CLIENTS.keys())
	client_ids.sort()
	var client_id := client_ids[rng.randi_range(0, client_ids.size() - 1)]
	var template_id := _template_for_client(client_id)
	var client: Dictionary = CLIENTS[client_id]
	var template: Dictionary = CONTRACT_TEMPLATES[template_id]
	var biome_options: Array = client.preferred_biomes
	var biome := String(biome_options[rng.randi_range(0, biome_options.size() - 1)])
	var difficulty_tier := clampi(1 + reputation / 25, 1, 5)
	active_contract = {
		"id": "%s_%s_%s" % [client_id, template_id, seed],
		"seed": seed,
		"client_id": client_id,
		"client": client.duplicate(true),
		"template_id": template_id,
		"objective": template.objective,
		"brief": client.brief,
		"biome": biome,
		"difficulty_tier": difficulty_tier,
		"base_payment": int(template.base_payment) + difficulty_tier * 15,
		"base_reputation": int(template.base_reputation) + difficulty_tier,
		"clauses": Array(template.clauses).duplicate(true),
	}
	return active_contract.duplicate(true)

func evaluate_contract(metrics: Dictionary) -> Dictionary:
	if active_contract.is_empty():
		return {"ok": false, "satisfaction": 0.0, "payment": 0, "reputation": 0}
	var total_weight := 0.0
	var earned_weight := 0.0
	var clause_results: Array[Dictionary] = []
	for clause in active_contract.clauses:
		var weight := float(clause.get("weight", 0.0))
		var passed := _evaluate_clause(clause, metrics)
		total_weight += weight
		if passed:
			earned_weight += weight
		clause_results.append({"id": clause.id, "passed": passed, "weight": weight})
	var satisfaction := 0.0 if total_weight <= 0.0 else earned_weight / total_weight
	var payment_multiplier := lerpf(0.40, 1.25, satisfaction)
	var reputation_multiplier := lerpf(0.25, 1.20, satisfaction)
	var payment := int(round(float(active_contract.base_payment) * payment_multiplier))
	var reputation := int(round(float(active_contract.base_reputation) * reputation_multiplier))
	if satisfaction >= 0.999:
		payment += 25
		reputation += 2
	completed_contracts.append(String(active_contract.id))
	return {
		"ok": true,
		"contract_id": active_contract.id,
		"client_id": active_contract.client_id,
		"satisfaction": satisfaction,
		"grade": _grade_for_satisfaction(satisfaction),
		"payment": payment,
		"reputation": reputation,
		"clause_results": clause_results,
	}

func get_briefing() -> Dictionary:
	if active_contract.is_empty():
		return {}
	return {
		"client_name": active_contract.client.name,
		"client_title": active_contract.client.title,
		"brief": active_contract.brief,
		"biome": active_contract.biome,
		"objective": active_contract.objective,
		"clauses": active_contract.clauses.duplicate(true),
		"estimated_payment": active_contract.base_payment,
	}

func to_dict() -> Dictionary:
	return {
		"active_contract": active_contract.duplicate(true),
		"completed_contracts": completed_contracts.duplicate(),
	}

func from_dict(data: Dictionary) -> void:
	active_contract = Dictionary(data.get("active_contract", {})).duplicate(true)
	completed_contracts.assign(data.get("completed_contracts", []))

func _template_for_client(client_id: String) -> String:
	match client_id:
		"lich":
			return "protect_relic"
		"dragon":
			return "protect_treasure"
		"spider_queen":
			return "capture_alive"
		"vampire":
			return "elegant_defense"
	return "protect_relic"

func _evaluate_clause(clause: Dictionary, metrics: Dictionary) -> bool:
	match String(clause.id):
		"target_untouched":
			return not bool(metrics.get("target_damaged", false))
		"minimum_captures":
			return int(metrics.get("captures", 0)) >= int(clause.get("target", 0))
		"budget_respected":
			return int(metrics.get("spent", 0)) <= int(metrics.get("budget", 0))
		"low_lethal_damage":
			return float(metrics.get("lethal_damage_ratio", 1.0)) <= float(clause.get("max", 0.0))
		"family_required":
			return String(clause.get("family", "")) in Array(metrics.get("families", []))
		"treasure_retained":
			return float(metrics.get("treasure_retained", 0.0)) >= float(clause.get("min", 1.0))
		"elite_defeated":
			return int(metrics.get("elites_defeated", 0)) >= int(clause.get("target", 0))
		"trap_damage":
			return int(metrics.get("trap_damage", 0)) >= int(clause.get("min", 0))
		"wall_loss_limit":
			return int(metrics.get("walls_lost", 999)) <= int(clause.get("max", 0))
		"room_variety":
			return int(metrics.get("room_variety", 0)) >= int(clause.get("target", 0))
	return false

func _grade_for_satisfaction(value: float) -> String:
	if value >= 0.999:
		return "S"
	if value >= 0.75:
		return "A"
	if value >= 0.50:
		return "B"
	if value >= 0.25:
		return "C"
	return "D"
