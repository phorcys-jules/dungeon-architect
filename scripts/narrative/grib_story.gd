class_name GribStory
extends RefCounted

const PROTAGONIST := {
	"id": "grib",
	"name": "Grib",
	"species": "goblin",
	"role": "Dungeon Architect",
	"dream": "Devenir Architecte Royal des Ténèbres",
	"starting_reputation": 0,
}

const INTRO_STEPS := [
	{
		"id": "wake_in_shed",
		"speaker": "Grib",
		"text": "Un établi bancal, trois clous tordus et zéro client. Parfait. Il faut bien commencer quelque part.",
		"objective": "inspect_workbench",
	},
	{
		"id": "first_blueprint",
		"speaker": "Grib",
		"text": "Un bon donjon commence par un plan. Un excellent donjon commence par un acompte.",
		"objective": "open_blueprint_table",
	},
	{
		"id": "first_client",
		"speaker": "Maître Ossuaire",
		"text": "Gobelin, protège mon reliquaire. Surprends-moi et je parlerai de toi aux autres seigneurs.",
		"objective": "accept_first_contract",
	},
	{
		"id": "build_first_room",
		"speaker": "Grib",
		"text": "Des murs, un détour, un piège. Les héros appellent ça une épreuve. Moi, j'appelle ça une facture.",
		"objective": "complete_build_tutorial",
	},
	{
		"id": "return_to_workshop",
		"speaker": "Grib",
		"text": "Premier contrat terminé. L'atelier est encore minuscule, mais le village connaît désormais mon nom.",
		"objective": "claim_first_payment",
	},
]

var completed_steps: Array[String] = []
var current_step_index := 0
var intro_completed := false
var first_contract_id := ""

func protagonist() -> Dictionary:
	return PROTAGONIST.duplicate(true)

func current_step() -> Dictionary:
	if intro_completed or current_step_index >= INTRO_STEPS.size():
		return {}
	return INTRO_STEPS[current_step_index].duplicate(true)

func complete_objective(objective_id: String) -> Dictionary:
	var step := current_step()
	if step.is_empty():
		return {"ok": false, "reason": "complete"}
	if String(step.objective) != objective_id:
		return {"ok": false, "reason": "wrong_objective", "expected": step.objective}
	completed_steps.append(String(step.id))
	current_step_index += 1
	intro_completed = current_step_index >= INTRO_STEPS.size()
	return {"ok": true, "completed_step": step.id, "intro_completed": intro_completed, "next_step": current_step()}

func set_first_contract(contract_id: String) -> void:
	first_contract_id = contract_id

func view_model() -> Dictionary:
	return {
		"protagonist": protagonist(),
		"current_step": current_step(),
		"completed_steps": completed_steps.duplicate(),
		"progress": float(completed_steps.size()) / float(INTRO_STEPS.size()),
		"intro_completed": intro_completed,
		"first_contract_id": first_contract_id,
	}

func to_dict() -> Dictionary:
	return {
		"completed_steps": completed_steps.duplicate(),
		"current_step_index": current_step_index,
		"intro_completed": intro_completed,
		"first_contract_id": first_contract_id,
	}

func from_dict(data: Dictionary) -> void:
	completed_steps.clear()
	for step_id in data.get("completed_steps", []):
		completed_steps.append(String(step_id))
	current_step_index = clampi(int(data.get("current_step_index", completed_steps.size())), 0, INTRO_STEPS.size())
	intro_completed = bool(data.get("intro_completed", current_step_index >= INTRO_STEPS.size()))
	first_contract_id = String(data.get("first_contract_id", ""))
