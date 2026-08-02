extends SceneTree

func _init() -> void:
    var paths := [
        "res://resources/rooms/corridor.tres",
        "res://resources/rooms/crossroads.tres",
        "res://resources/rooms/treasure_hall.tres",
    ]
    var rooms: Array[RoomData] = []
    for path: String in paths:
        var room := load(path) as RoomData
        if room == null or not room.is_valid():
            push_error("Invalid room resource: %s" % path)
            quit(1)
            return
        rooms.append(room)

    var deck := RoomDeck.new()
    deck.configure(rooms)
    if not deck.select([&"corridor", &"crossroads", &"treasure_hall"]):
        push_error("Room selection failed")
        quit(1)
        return
    deck.shuffle(2026)
    var first_order: Array[String] = []
    while deck.remaining() > 0:
        first_order.append(deck.draw().room_id)

    deck.shuffle(2026)
    var second_order: Array[String] = []
    while deck.remaining() > 0:
        second_order.append(deck.draw().room_id)

    if first_order != second_order:
        push_error("Room deck is not deterministic")
        quit(1)
        return

    print("Room deck test passed")
    quit(0)
