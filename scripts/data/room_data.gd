class_name RoomData
extends Resource

enum Rarity { COMMON, UNCOMMON, RARE, LEGENDARY }

@export var room_id := ""
@export var display_name := ""
@export var rarity := Rarity.COMMON
@export var build_cost := 10
@export var tags: Array[StringName] = []
@export var connections: Array[Vector2i] = []
@export var max_copies := 3

func is_valid() -> bool:
    return (
        not room_id.is_empty()
        and not display_name.is_empty()
        and build_cost >= 0
        and max_copies > 0
        and not connections.is_empty()
    )
