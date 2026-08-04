class_name VillageNarrativeGrowth
extends RefCounted

const STAGES := [
	{
		"id": "lonely_workshop",
		"name": "L’atelier isolé",
		"min_reputation": 0,
		"min_contracts": 0,
		"buildings": ["workshop"],
		"population": 1,
		"story": "Grib travaille seul dans une remise au bord du marais.",
	},
	{
		"id": "first_camp",
		"name": "Le premier campement",
		"min_reputation": 5,
		"min_contracts": 1,
		"buildings": ["workshop", "goblin_tent"],
		"population": 4,
		"story": "Quelques gobelins viennent aider Grib après son premier contrat.",
	},
	{
		"id": "craft_hamlet",
		"name": "Le hameau des artisans",
		"min_reputation": 20,
		"min_contracts": 4,
		"buildings": ["workshop", "goblin_tent", "forge", "tavern"],
		"population": 12,
		"story": "Forgerons et fournisseurs s’installent autour de l’atelier.",
	},
	{
		"id": "monster_village",
		"name": "Le village des monstres",
		"min_reputation": 50,
		"min_contracts": 10,
		"buildings": ["workshop", "forge", "tavern", "market", "laboratory", "houses"],
		"population": 35,
		"story": "L’activité de Grib fait vivre une véritable communauté monstrueuse.",
	},
	{
		"id": "architect_city",
		"name": "La cité des architectes",
		"min_reputation": 100,
		"min_contracts": 20,
		"buildings": ["workshop", "forge", "tavern", "market", "laboratory", "archives", "guild_hall", "houses"],
		"population": 80,
		"story": "Les plus grands Seigneurs du Mal viennent désormais négocier en personne.",
	},
]

var reputation := 0
var completed_contracts := 0
var current_stage_index := 0
var unlocked_events: Array[String] = []

func record_contract(reputation_gain: int) -> Dictionary:
	completed_contracts += 1
	reputation = maxi(0, reputation + reputation_gain)
	return refresh_progression()

func refresh_progression() -> Dictionary:
	var previous_index := current_stage_index
	for index in range(STAGES.size()):
		var stage: Dictionary = STAGES[index]
		if reputation >= int(stage.min_reputation) and completed_contracts >= int(stage.min_contracts):
			current_stage_index = index
	if current_stage_index > previous_index:
		for index in range(previous_index + 1, current_stage_index + 1):
			unlocked_events.append(String(STAGES[index].id))
	return view_model()

func current_stage() -> Dictionary:
	return (STAGES[current_stage_index] as Dictionary).duplicate(true)

func view_model() -> Dictionary:
	var stage := current_stage()
	var next_stage: Dictionary = {}
	if current_stage_index + 1 < STAGES.size():
		next_stage = (STAGES[current_stage_index + 1] as Dictionary).duplicate(true)
	return {
		"stage": stage,
		"next_stage": next_stage,
		"reputation": reputation,
		"completed_contracts": completed_contracts,
		"unlocked_events": unlocked_events.duplicate(),
		"village_is_player_built": false,
	}

func to_dict() -> Dictionary:
	return {
		"reputation": reputation,
		"completed_contracts": completed_contracts,
		"current_stage_index": current_stage_index,
		"unlocked_events": unlocked_events.duplicate(),
	}

func from_dict(data: Dictionary) -> void:
	reputation = maxi(0, int(data.get("reputation", 0)))
	completed_contracts = maxi(0, int(data.get("completed_contracts", 0)))
	current_stage_index = clampi(int(data.get("current_stage_index", 0)), 0, STAGES.size() - 1)
	unlocked_events.clear()
	for event_id in data.get("unlocked_events", []):
		unlocked_events.append(String(event_id))
	refresh_progression()
