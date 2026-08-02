class_name TreasureChestState
extends RefCounted

enum State { LOCKED, OPEN, CHANNELING, STOLEN, RECOVERED }

var state: State = State.LOCKED
var channel_duration := 3.0
var channel_progress := 0.0
var carrier_id := ""

func unlock() -> void:
    if state == State.LOCKED:
        state = State.OPEN

func begin_steal(adventurer_id: String) -> bool:
    if state != State.OPEN or adventurer_id.is_empty():
        return false
    carrier_id = adventurer_id
    channel_progress = 0.0
    state = State.CHANNELING
    return true

func tick_channel(delta: float, interrupted: bool = false) -> bool:
    if state != State.CHANNELING:
        return false
    if interrupted:
        cancel_channel()
        return false
    channel_progress = minf(channel_progress + maxf(delta, 0.0), channel_duration)
    if channel_progress >= channel_duration:
        state = State.STOLEN
        return true
    return false

func cancel_channel() -> void:
    if state == State.CHANNELING:
        state = State.OPEN
        channel_progress = 0.0
        carrier_id = ""

func recover() -> bool:
    if state != State.STOLEN:
        return false
    state = State.RECOVERED
    carrier_id = ""
    return true

func is_carried() -> bool:
    return state == State.STOLEN and not carrier_id.is_empty()

func progress_ratio() -> float:
    if channel_duration <= 0.0:
        return 1.0
    return clampf(channel_progress / channel_duration, 0.0, 1.0)
