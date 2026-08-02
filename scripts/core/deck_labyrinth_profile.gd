class_name DeckLabyrinthProfile
extends RefCounted

func apply(generator: LabyrinthGenerator, room_tags: Array[StringName]) -> Dictionary:
    var original_density := generator.wall_density
    var original_loops := generator.minimum_loops
    if room_tags.has(&"corridor"):
        generator.wall_density = maxf(generator.wall_density - 0.05, 0.18)
    if room_tags.has(&"junction"):
        generator.minimum_loops += 3
    if room_tags.has(&"treasure"):
        generator.minimum_loops += 1
    return {"wall_density": original_density, "minimum_loops": original_loops}

func restore(generator: LabyrinthGenerator, snapshot: Dictionary) -> void:
    generator.wall_density = float(snapshot.get("wall_density", generator.wall_density))
    generator.minimum_loops = int(snapshot.get("minimum_loops", generator.minimum_loops))

func generate(generator: LabyrinthGenerator, seed_value: int, required_cells: Array[Vector2i], room_tags: Array[StringName]) -> Dictionary:
    var snapshot := apply(generator, room_tags)
    var layout := generator.generate(seed_value, required_cells)
    layout["room_tags"] = room_tags.duplicate()
    restore(generator, snapshot)
    return layout
