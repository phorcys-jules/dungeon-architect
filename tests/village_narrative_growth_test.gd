extends SceneTree

func _init() -> void:
	var village := VillageNarrativeGrowth.new()
	assert(village.current_stage().id == "lonely_workshop")
	assert(not bool(village.view_model().village_is_player_built))

	village.record_contract(5)
	assert(village.current_stage().id == "first_camp")
	assert(village.unlocked_events.has("first_camp"))

	for index in range(3):
		village.record_contract(5)
	assert(village.current_stage().id == "craft_hamlet")
	assert(village.current_stage().buildings.has("forge"))

	var saved := village.to_dict()
	var restored := VillageNarrativeGrowth.new()
	restored.from_dict(saved)
	assert(restored.current_stage().id == "craft_hamlet")
	assert(restored.completed_contracts == 4)

	print("village narrative growth test passed")
	quit()
