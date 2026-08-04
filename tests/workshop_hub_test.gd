extends SceneTree


func _init() -> void:
	var workshop := WorkshopHub.new()
	var initial := workshop.enter()
	assert(initial.title == "Atelier du Dungeon Architect")
	assert(initial.active_station == "contracts")
	assert(workshop.visual_stage("contracts") == "makeshift")
	assert(not workshop.select_station("forge"))

	workshop.add_resources({
		"payment": 500,
		"materials": 200,
		"blueprints": 50,
		"reputation": 12,
	})
	assert(workshop.can_upgrade("forge"))
	var result := workshop.upgrade("forge")
	assert(result.ok)
	assert(result.level == 1)
	assert(workshop.select_station("forge"))
	assert(workshop.visual_stage("forge") == "makeshift")

	var saved := workshop.to_dict()
	var restored := WorkshopHub.new()
	restored.from_dict(saved)
	assert(restored.active_station == "forge")
	assert(int(restored.module_levels.forge) == 1)
	assert(int(restored.resources.reputation) == 12)

	print("workshop hub test passed")
	quit()
