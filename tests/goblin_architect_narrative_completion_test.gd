extends SceneTree

func _init() -> void:
	var residents := VillageResidents.new()
	var initial_residents := residents.refresh(0, 0)
	assert(initial_residents.size() == 1)
	assert(initial_residents[0].id == "contract_steward")
	var developed_residents := residents.refresh(65, 13)
	assert(developed_residents.size() == 6)
	var restored_residents := VillageResidents.new()
	restored_residents.from_dict(residents.to_dict())
	assert(restored_residents.active_residents().size() == 6)

	var campaign := ArchitectCampaign.new()
	assert(campaign.current_act().id == "apprentice")
	for index in range(20):
		campaign.record_contract(5)
	assert(campaign.current_act().id == "royal_commission")
	assert(campaign.available_clients().has("demon_lord"))
	assert(bool(campaign.view_model().free_mode_unlocked))
	assert(bool(campaign.view_model().endless_mode_unlocked))

	var final_contract := DemonLordFinalContract.new()
	var workshop_levels := {"contracts": 2, "blueprints": 2, "forge": 2, "laboratory": 2}
	assert(final_contract.is_available(100, 20, workshop_levels))
	var result := final_contract.evaluate({"waves_survived": 5, "treasure_retained": 1.0, "elites_captured": 3, "synergies_activated": 4})
	assert(result.completed)
	assert(result.royal_title_unlocked)
	assert(result.grade == "S")
	var restored_contract := DemonLordFinalContract.new()
	restored_contract.from_dict(final_contract.to_dict())
	assert(restored_contract.royal_title_unlocked)

	print("goblin architect narrative completion test passed")
	quit()
