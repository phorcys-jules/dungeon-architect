class_name GameVersion
extends RefCounted

const VALUE := "v0.6.0-alpha"
const SAVE_VERSION := 4

static func display_name() -> String:
    return "Dungeon Architect %s" % VALUE
