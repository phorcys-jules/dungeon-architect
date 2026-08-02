extends SceneTree

func _init() -> void:
    var rooms: Array[RoomData] = [
        load("res://resources/rooms/corridor.tres") as RoomData,
        load("res://resources/rooms/crossroads.tres") as RoomData,
        load("res://resources/rooms/treasure_hall.tres") as RoomData,
    ]
    var loadout := RoomLoadout.new()
    loadout.configure(rooms)
    if not loadout.select_default():
        quit(1)
        return
    var generator := LabyrinthGenerator.new()
    var profile := DeckLabyrinthProfile.new()
    var required: Array[Vector2i] = [Vector2i(2, 2), Vector2i(12, 8)]
    var first := profile.generate(generator, 3030, required, loadout.get_tags())
    var second := profile.generate(generator, 3030, required, loadout.get_tags())
    if not generator.is_valid(first, required):
        quit(1)
        return
    if generator.fingerprint(first) != generator.fingerprint(second):
        quit(1)
        return
    if not (first.get("room_tags", []) as Array).has(&"junction"):
        quit(1)
        return
    print("Room loadout labyrinth test passed")
    quit(0)
