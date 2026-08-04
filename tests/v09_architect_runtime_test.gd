extends SceneTree


func _init() -> void:
	var runtime := V09ArchitectRuntime.new()
	var hub := runtime.enter_hub()
	assert(hub.has("workshop"))
	assert(hub.has("campaign"))
	assert(Array(hub.residents).size() >= 1)

	var offer := runtime.generate_contract(909)
	assert(not Dictionary(offer.contract).is_empty())
	assert(not String(offer.architect_context.title).is_empty())

	var result := runtime.complete_contract({
		"target_damaged": false,
		"captures": 20,
		"spent": 10,
		"budget": 999,
		"lethal_damage_ratio": 0.0,
		"families": ["beast"],
		"treasure_retained": 1.0,
		"elites_defeated": 5,
		"trap_damage": 999,
		"walls_lost": 0,
		"room_variety": 8,
		"blueprints_found": 2,
		"materials_salvaged": 5,
	})
	assert(result.ok)
	assert(int(runtime.workshop.resources.payment) > 0)
	assert(runtime.campaign.completed_contracts == 1)
	assert(runtime.village.completed_contracts == 1)

	var saved := runtime.to_dict()
	var restored := V09ArchitectRuntime.new()
	restored.from_dict(saved)
	assert(restored.campaign.completed_contracts == 1)
	assert(int(restored.workshop.resources.payment) == int(runtime.workshop.resources.payment))

	print("v0.9 architect runtime test passed")
	quit()
