class_name GameVersion
extends RefCounted

const VALUE := "v0.8.0-alpha"
const SAVE_VERSION := 6

static func display_name() -> String:
    return "Dungeon Architect %s" % VALUE
