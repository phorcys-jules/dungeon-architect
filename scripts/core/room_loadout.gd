class_name RoomLoadout
extends RefCounted

const MAX_ROOMS := 5
const DEFAULT_IDS: Array[StringName] = [&"corridor", &"corridor", &"crossroads", &"treasure_hall"]

var deck := RoomDeck.new()
var selected_ids: Array[StringName] = []

func configure(rooms: Array[RoomData]) -> void:
    deck.configure(rooms)

func select(room_ids: Array[StringName]) -> bool:
    if room_ids.is_empty() or room_ids.size() > MAX_ROOMS:
        return false
    if not deck.select(room_ids):
        return false
    selected_ids = room_ids.duplicate()
    return true

func select_default() -> bool:
    return select(DEFAULT_IDS)

func get_tags() -> Array[StringName]:
    var tags: Array[StringName] = []
    for room_id: StringName in selected_ids:
        var room: RoomData = deck.catalog.get(room_id) as RoomData
        if room == null:
            continue
        for tag: StringName in room.tags:
            if not tags.has(tag):
                tags.append(tag)
    return tags

func get_room_ids() -> Array[StringName]:
    return selected_ids.duplicate()
