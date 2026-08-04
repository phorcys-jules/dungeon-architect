class_name V09ArchitectRuntime
extends RefCounted

var workshop := WorkshopHub.new()
var upgrades := WorkshopUpgradeTree.new()
var contracts := MonsterContractSystem.new()
var story := GribStory.new()
var village := VillageNarrativeGrowth.new()
var residents := VillageResidents.new()
var campaign := ArchitectCampaign.new()
var final_contract := DemonLordFinalContract.new()

var active_contract: Dictionary = {}
var last_result: Dictionary = {}


func enter_hub() -> Dictionary:
	var campaign_state := campaign.view_model()
	var village_state := village.view_model()
	var resident_state := residents.refresh(
		int(village_state.reputation),
		int(village_state.completed_contracts)
	)
	return {
		"workshop": workshop.enter(),
		"story": story.view_model(),
		"village": village_state,
		"residents": resident_state,
		"campaign": campaign_state,
		"upgrades": upgrades.combined_effects(),
		"last_result": last_result.duplicate(true),
	}


func generate_contract(seed: int) -> Dictionary:
	var reputation := int(workshop.resources.get("reputation", 0))
	active_contract = contracts.generate_contract(seed, reputation)
	story.set_first_contract(String(active_contract.get("id", "")))
	var client: Dictionary = active_contract.get("client", {})
	var context_data := active_contract.duplicate(true)
	context_data["client_name"] = String(client.get("name", "Client confidentiel"))
	return {
		"contract": active_contract.duplicate(true),
		"briefing": contracts.get_briefing(),
		"architect_context": ArchitectContext.contract_summary(context_data),
		"workshop_effects": upgrades.combined_effects(),
		"campaign": campaign.view_model(),
	}


func complete_contract(metrics: Dictionary) -> Dictionary:
	var result := contracts.evaluate_contract(metrics)
	if not bool(result.get("ok", false)):
		return result
	var rewards := {
		"payment": int(result.get("payment", 0)),
		"reputation": int(result.get("reputation", 0)),
		"blueprints": int(metrics.get("blueprints_found", 0)),
		"materials": int(metrics.get("materials_salvaged", 0)),
	}
	workshop.add_resources(rewards)
	var reputation_gain := int(result.get("reputation", 0))
	var village_state := village.record_contract(reputation_gain)
	var campaign_state := campaign.record_contract(reputation_gain)
	residents.refresh(int(village_state.reputation), int(village_state.completed_contracts))
	last_result = result.duplicate(true)
	last_result["rewards"] = rewards
	last_result["village"] = village_state
	last_result["campaign"] = campaign_state
	active_contract.clear()
	return last_result.duplicate(true)


func final_contract_available() -> bool:
	return final_contract.is_available(
		campaign.reputation,
		campaign.completed_contracts,
		workshop.module_levels
	) and not final_contract.completed


func begin_final_contract() -> Dictionary:
	if not final_contract_available():
		return {"ok": false, "reason": "locked"}
	var briefing := final_contract.briefing()
	briefing["ok"] = true
	return briefing


func complete_final_contract(metrics: Dictionary) -> Dictionary:
	var result := final_contract.evaluate(metrics)
	if bool(result.get("completed", false)):
		last_result = result.duplicate(true)
	return result


func to_dict() -> Dictionary:
	return {
		"workshop": workshop.to_dict(),
		"upgrades": upgrades.to_dict(),
		"contracts": contracts.to_dict(),
		"story": story.to_dict(),
		"village": village.to_dict(),
		"residents": residents.to_dict(),
		"campaign": campaign.to_dict(),
		"final_contract": final_contract.to_dict(),
		"active_contract": active_contract.duplicate(true),
		"last_result": last_result.duplicate(true),
	}


func from_dict(data: Dictionary) -> void:
	workshop.from_dict(data.get("workshop", {}))
	upgrades.from_dict(data.get("upgrades", {}))
	contracts.from_dict(data.get("contracts", {}))
	story.from_dict(data.get("story", {}))
	village.from_dict(data.get("village", {}))
	residents.from_dict(data.get("residents", {}))
	campaign.from_dict(data.get("campaign", {}))
	final_contract.from_dict(data.get("final_contract", {}))
	active_contract = Dictionary(data.get("active_contract", {})).duplicate(true)
	last_result = Dictionary(data.get("last_result", {})).duplicate(true)
