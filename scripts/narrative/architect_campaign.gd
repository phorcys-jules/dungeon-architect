class_name ArchitectCampaign
extends RefCounted

const ACTS := [
	{"id": "apprentice", "name": "L’apprenti inconnu", "min_reputation": 0, "min_contracts": 0, "clients": ["lich"], "biomes": ["crypt"], "story": "Grib accepte les chantiers que les architectes respectables refusent."},
	{"id": "recognized", "name": "L’atelier reconnu", "min_reputation": 20, "min_contracts": 4, "clients": ["lich", "spider_queen", "vampire"], "biomes": ["crypt", "sewer", "castle"], "story": "Les clients régionaux commencent à faire le déplacement jusqu’à l’atelier."},
	{"id": "master_builder", "name": "Le maître bâtisseur", "min_reputation": 60, "min_contracts": 12, "clients": ["dragon", "lich", "vampire", "spider_queen"], "biomes": ["mine", "castle", "crypt", "sewer"], "story": "Les grandes puissances monstrueuses se disputent le calendrier de Grib."},
	{"id": "royal_commission", "name": "La commande royale", "min_reputation": 100, "min_contracts": 20, "clients": ["demon_lord"], "biomes": ["infernal_citadel"], "story": "Le Seigneur Démon convoque Grib pour le chantier qui décidera de son titre."},
]

var reputation := 0
var completed_contracts := 0
var current_act_index := 0
var completed_transitions: Array[String] = []

func record_contract(reputation_gain: int) -> Dictionary:
	completed_contracts += 1
	reputation = maxi(0, reputation + reputation_gain)
	return refresh()

func refresh() -> Dictionary:
	var previous := current_act_index
	for index in range(ACTS.size()):
		var act: Dictionary = ACTS[index]
		if reputation >= int(act.min_reputation) and completed_contracts >= int(act.min_contracts):
			current_act_index = index
	if current_act_index > previous:
		for index in range(previous + 1, current_act_index + 1):
			completed_transitions.append(String(ACTS[index].id))
	return view_model()

func current_act() -> Dictionary:
	return (ACTS[current_act_index] as Dictionary).duplicate(true)

func available_clients() -> Array:
	return Array(current_act().clients).duplicate()

func view_model() -> Dictionary:
	var next_act: Dictionary = {}
	if current_act_index + 1 < ACTS.size():
		next_act = (ACTS[current_act_index + 1] as Dictionary).duplicate(true)
	return {"act": current_act(), "next_act": next_act, "reputation": reputation, "completed_contracts": completed_contracts, "transitions": completed_transitions.duplicate(), "free_mode_unlocked": current_act_index >= 1, "endless_mode_unlocked": current_act_index >= 2}

func to_dict() -> Dictionary:
	return {"reputation": reputation, "completed_contracts": completed_contracts, "current_act_index": current_act_index, "completed_transitions": completed_transitions.duplicate()}

func from_dict(data: Dictionary) -> void:
	reputation = maxi(0, int(data.get("reputation", 0)))
	completed_contracts = maxi(0, int(data.get("completed_contracts", 0)))
	current_act_index = clampi(int(data.get("current_act_index", 0)), 0, ACTS.size() - 1)
	completed_transitions.clear()
	for transition in data.get("completed_transitions", []):
		completed_transitions.append(String(transition))
	refresh()
