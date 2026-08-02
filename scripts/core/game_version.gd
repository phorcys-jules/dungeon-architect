class_name GameVersion
extends RefCounted

const VALUE := "v0.3.0-alpha"
const SAVE_VERSION := 1

static func display_name() -> String:
    return "Dungeon Architect %s" % VALUE
