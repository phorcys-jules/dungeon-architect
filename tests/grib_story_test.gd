extends SceneTree

func _init() -> void:
	var story := GribStory.new()
	assert(story.protagonist().name == "Grib")
	assert(story.current_step().id == "wake_in_shed")
	assert(not story.complete_objective("wrong").ok)

	for objective_id in [
		"inspect_workbench",
		"open_blueprint_table",
		"accept_first_contract",
		"complete_build_tutorial",
		"claim_first_payment",
	]:
		assert(story.complete_objective(objective_id).ok)

	assert(story.intro_completed)
	assert(story.current_step().is_empty())
	story.set_first_contract("liche_intro_001")

	var saved := story.to_dict()
	var restored := GribStory.new()
	restored.from_dict(saved)
	assert(restored.intro_completed)
	assert(restored.first_contract_id == "liche_intro_001")
	assert(restored.completed_steps.size() == 5)

	print("grib story test passed")
	quit()
