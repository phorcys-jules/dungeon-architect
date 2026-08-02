class_name GameVersion
extends RefCounted

const VALUE := "v0.5.0-alpha"
const SAVE_VERSION := 3

static func display_name() -> String:
    return "Dungeon Architect %s" % VALUE
