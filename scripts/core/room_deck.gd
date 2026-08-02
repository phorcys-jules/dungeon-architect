class_name RoomDeck
extends RefCounted

var catalog: Dictionary = {}
var selected_ids: Array[StringName] = []
var draw_pile: Array[StringName] = []

func configure(rooms: Array[RoomData]) -> void:
    catalog.clear()
    for room: RoomData in rooms:
        if room != null and room.is_valid():
            catalog[StringName(room.room_id)] = room

func select(room_ids: Array[StringName]) -> bool:
    var counts: Dictionary = {}
    for room_id: StringName in room_ids:
        if not catalog.has(room_id):
            return false
        counts[room_id] = int(counts.get(room_id, 0)) + 1
        var room: RoomData = catalog[room_id]
        if counts[room_id] > room.max_copies:
            return false
    selected_ids = room_ids.duplicate()
    return not selected_ids.is_empty()

func shuffle(seed_value: int) -> void:
    draw_pile = selected_ids.duplicate()
    var rng := RandomNumberGenerator.new()
    rng.seed = seed_value
    for index: int in range(draw_pile.size() - 1, 0, -1):
        var swap_index: int = rng.randi_range(0, index)
        var temporary: StringName = draw_pile[index]
        draw_pile[index] = draw_pile[swap_index]
        draw_pile[swap_index] = temporary

func draw() -> RoomData:
    if draw_pile.is_empty():
        return null
    var room_id: StringName = draw_pile.pop_front()
    return catalog.get(room_id) as RoomData

func remaining() -> int:
    return draw_pile.size()
