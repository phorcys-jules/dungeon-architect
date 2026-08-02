extends SceneTree

const ROOM_PATHS := [
    "res://resources/rooms/fog_chamber.tres",
    "res://resources/rooms/slime_pool.tres",
    "res://resources/rooms/ice_gallery.tres",
    "res://resources/rooms/false_treasure.tres",
    "res://resources/rooms/monster_portal.tres",
    "res://resources/rooms/cursed_shrine.tres",
]

func _init() -> void:
    var rooms: Array[RoomData] = []
    var all_tags: Dictionary = {}
    for path: String in ROOM_PATHS:
        var room := load(path) as RoomData
        if room == null or not room.is_valid():
            push_error("Invalid special room: %s" % path)
            quit(1)
            return
        rooms.append(room)
        for tag: StringName in room.tags:
            all_tags[tag] = true

    for required_tag: StringName in [&"fog", &"slime", &"ice", &"mimic", &"portal", &"curse"]:
        if not all_tags.has(required_tag):
            push_error("Missing gameplay tag: %s" % required_tag)
            quit(1)
            return

    var deck := RoomDeck.new()
    deck.configure(rooms)
    var ids: Array[StringName] = []
    for room: RoomData in rooms:
        ids.append(StringName(room.room_id))
    if not deck.select(ids):
        push_error("Special room deck selection failed")
        quit(1)
        return
    deck.shuffle(4040)
    if deck.remaining() != ROOM_PATHS.size():
        quit(1)
        return

    print("Special room catalog test passed")
    quit(0)
