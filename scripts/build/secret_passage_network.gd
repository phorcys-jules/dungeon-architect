class_name SecretPassageNetwork
extends RefCounted

var passages: Array[Dictionary] = []

func add_passage(entry: Vector2i, exit: Vector2i, allowed_tags: Array[String]) -> bool:
    if entry == exit or allowed_tags.is_empty():
        return false
    if get_passage(entry) != null:
        return false
    passages.append({
        "entry": entry,
        "exit": exit,
        "allowed_tags": allowed_tags.duplicate(),
    })
    return true

func remove_passage(entry: Vector2i) -> bool:
    for index in passages.size():
        if passages[index].entry == entry:
            passages.remove_at(index)
            return true
    return false

func get_passage(entry: Vector2i) -> Variant:
    for passage in passages:
        if passage.entry == entry:
            return passage
    return null

func can_traverse(entry: Vector2i, actor_tags: Array[String]) -> bool:
    var passage: Variant = get_passage(entry)
    if passage == null:
        return false
    for required_tag: String in passage.allowed_tags:
        if actor_tags.has(required_tag):
            return true
    return false

func destination_for(entry: Vector2i, actor_tags: Array[String]) -> Vector2i:
    var passage: Variant = get_passage(entry)
    if passage == null or not can_traverse(entry, actor_tags):
        return entry
    return passage.exit

func navigation_edges(actor_tags: Array[String]) -> Array[Dictionary]:
    var result: Array[Dictionary] = []
    for passage in passages:
        if can_traverse(passage.entry, actor_tags):
            result.append({"from": passage.entry, "to": passage.exit})
    return result
