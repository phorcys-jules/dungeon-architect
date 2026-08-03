class_name WorkshopHub
extends RefCounted

const MODULES := {
	"contracts": {
		"name": "Bureau des contrats",
		"description": "Choisir les clients, consulter les clauses et négocier les récompenses.",
		"max_level": 5,
	},
	"blueprints": {
		"name": "Salle des plans",
		"description": "Débloquer salles, murs, portes, passages et biomes.",
		"max_level": 5,
	},
	"forge": {
		"name": "Établi et forge",
		"description": "Améliorer les pièges et les outils de chantier.",
		"max_level": 5,
	},
	"laboratory": {
		"name": "Laboratoire",
		"description": "Recruter, faire évoluer et spécialiser les monstres.",
		"max_level": 5,
	},
	"archives": {
		"name": "Archives",
		"description": "Consulter découvertes, statistiques et succès.",
		"max_level": 3,
	},
	"trophies": {
		"name": "Salle des trophées",
		"description": "Exposer les reliques et souvenirs des contrats prestigieux.",
		"max_level": 3,
	},
}

var resources := {
	"payment": 0,
	"reputation": 0,
	"blueprints": 0,
	"materials": 0,
}
var module_levels: Dictionary = {}
var active_station := "contracts"
var visit_count := 0


func _init() -> void:
	for module_id in MODULES:
		module_levels[module_id] = 0
	module_levels["contracts"] = 1


func enter() -> Dictionary:
	visit_count += 1
	return view_model()


func add_resources(rewards: Dictionary) -> void:
	for resource_id in resources:
		resources[resource_id] = maxi(
			0,
			int(resources[resource_id]) + int(rewards.get(resource_id, 0))
		)


func upgrade_cost(module_id: String) -> Dictionary:
	if not MODULES.has(module_id):
		return {}
	var next_level := int(module_levels.get(module_id, 0)) + 1
	return {
		"payment": 80 * next_level,
		"materials": 25 * next_level,
		"blueprints": 5 * maxi(0, next_level - 1),
	}


func can_upgrade(module_id: String) -> bool:
	if not MODULES.has(module_id):
		return false
	if int(module_levels.get(module_id, 0)) >= int(MODULES[module_id].max_level):
		return false
	var cost := upgrade_cost(module_id)
	for resource_id in cost:
		if int(resources.get(resource_id, 0)) < int(cost[resource_id]):
			return false
	return true


func upgrade(module_id: String) -> Dictionary:
	if not can_upgrade(module_id):
		return {"ok": false, "reason": "requirements"}
	var cost := upgrade_cost(module_id)
	for resource_id in cost:
		resources[resource_id] = int(resources[resource_id]) - int(cost[resource_id])
	module_levels[module_id] = int(module_levels[module_id]) + 1
	return {
		"ok": true,
		"module_id": module_id,
		"level": int(module_levels[module_id]),
		"visual_stage": visual_stage(module_id),
	}


func select_station(module_id: String) -> bool:
	if not MODULES.has(module_id):
		return false
	if int(module_levels.get(module_id, 0)) <= 0:
		return false
	active_station = module_id
	return true


func visual_stage(module_id: String) -> String:
	var level := int(module_levels.get(module_id, 0))
	if level <= 0:
		return "locked"
	if level == 1:
		return "makeshift"
	if level <= 3:
		return "established"
	return "masterwork"


func view_model() -> Dictionary:
	var stations: Array[Dictionary] = []
	for module_id in MODULES:
		stations.append({
			"id": module_id,
			"name": String(MODULES[module_id].name),
			"description": String(MODULES[module_id].description),
			"level": int(module_levels.get(module_id, 0)),
			"visual_stage": visual_stage(module_id),
			"selected": active_station == module_id,
			"upgrade_cost": upgrade_cost(module_id),
			"can_upgrade": can_upgrade(module_id),
		})
	return {
		"title": "Atelier du Dungeon Architect",
		"resources": resources.duplicate(true),
		"stations": stations,
		"active_station": active_station,
		"visit_count": visit_count,
	}


func to_dict() -> Dictionary:
	return {
		"resources": resources.duplicate(true),
		"module_levels": module_levels.duplicate(true),
		"active_station": active_station,
		"visit_count": visit_count,
	}


func from_dict(data: Dictionary) -> void:
	var saved_resources: Dictionary = data.get("resources", {})
	for resource_id in resources:
		resources[resource_id] = maxi(0, int(saved_resources.get(resource_id, 0)))
	var saved_levels: Dictionary = data.get("module_levels", {})
	for module_id in MODULES:
		module_levels[module_id] = clampi(
			int(saved_levels.get(module_id, module_levels.get(module_id, 0))),
			0,
			int(MODULES[module_id].max_level)
		)
	active_station = String(data.get("active_station", "contracts"))
	if not MODULES.has(active_station) or int(module_levels.get(active_station, 0)) <= 0:
		active_station = "contracts"
	visit_count = maxi(0, int(data.get("visit_count", 0)))
