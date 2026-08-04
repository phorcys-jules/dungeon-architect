extends SceneTree

func _init() -> void:
	var system := MonsterContractSystem.new()
	var contract := system.generate_contract(42, 30)
	assert(not contract.is_empty())
	assert(contract.has("client"))
	assert(contract.has("clauses"))
	assert(int(contract.difficulty_tier) == 2)
	var briefing := system.get_briefing()
	assert(not String(briefing.client_name).is_empty())
	assert(not String(briefing.brief).is_empty())

	var perfect_metrics := {
		"target_damaged": false,
		"captures": 10,
		"spent": 100,
		"budget": 200,
		"lethal_damage_ratio": 0.0,
		"families": ["beast"],
		"treasure_retained": 1.0,
		"elites_defeated": 3,
		"trap_damage": 500,
		"walls_lost": 0,
		"room_variety": 6,
	}
	var result := system.evaluate_contract(perfect_metrics)
	assert(bool(result.ok))
	assert(float(result.satisfaction) >= 0.999)
	assert(String(result.grade) == "S")
	assert(int(result.payment) > int(contract.base_payment))
	assert(system.completed_contracts.size() == 1)

	var restored := MonsterContractSystem.new()
	restored.from_dict(system.to_dict())
	assert(restored.completed_contracts == system.completed_contracts)
	assert(restored.active_contract.id == system.active_contract.id)

	var same_seed := MonsterContractSystem.new().generate_contract(42, 30)
	assert(same_seed.client_id == contract.client_id)
	assert(same_seed.biome == contract.biome)

	print("monster contracts test passed")
	quit()
