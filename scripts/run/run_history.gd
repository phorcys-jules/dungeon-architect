class_name RunHistory
extends RefCounted

const MAX_ENTRIES := 20
var entries: Array[RunResultRecord] = []

func add(record: RunResultRecord) -> void:
    entries.push_front(record)
    if entries.size() > MAX_ENTRIES:
        entries.resize(MAX_ENTRIES)

func to_array() -> Array:
    var result: Array = []
    for record in entries:
        result.append(record.to_dict())
    return result

func load_array(data: Array) -> void:
    entries.clear()
    for item in data.slice(0, MAX_ENTRIES):
        if item is Dictionary:
            entries.append(RunResultRecord.from_dict(item))
