extends SceneTree

func _fail(message: String) -> void:
    push_error(message)
    quit(1)

func _init() -> void:
    var planner := WallPlacementPlanner.new()
    planner.configure(Vector2i(5, 3), 2)
    var fixed: Array[Vector2i] = []
    var entrance := Vector2i(0, 1)
    var objective := Vector2i(4, 1)

    if not planner.place(Vector2i(2, 0), fixed, entrance, objective):
        _fail("A valid wall placement was rejected")
        return
    if planner.place(Vector2i(2, 1), [Vector2i(2, 2)], entrance, objective):
        _fail("A wall placement that blocks the final route was accepted")
        return
    if planner.remaining_budget() != 1:
        _fail("Wall budget was not updated")
        return
    if not planner.remove(Vector2i(2, 0)):
        _fail("Placed wall could not be removed")
        return

    var passages := SecretPassageNetwork.new()
    var monster_tags: Array[String] = ["ghost", "monster"]
    var adventurer_tags: Array[String] = ["adventurer"]
    if not passages.add_passage(Vector2i(1, 1), Vector2i(4, 2), ["ghost", "burrower"]):
        _fail("Secret passage could not be added")
        return
    if not passages.can_traverse(Vector2i(1, 1), monster_tags):
        _fail("Allowed monster could not use secret passage")
        return
    if passages.can_traverse(Vector2i(1, 1), adventurer_tags):
        _fail("Adventurer incorrectly used monster-only passage")
        return
    if passages.destination_for(Vector2i(1, 1), monster_tags) != Vector2i(4, 2):
        _fail("Secret passage returned the wrong destination")
        return
    if passages.destination_for(Vector2i(1, 1), adventurer_tags) != Vector2i(1, 1):
        _fail("Forbidden actor was moved through secret passage")
        return

    print("free walls and secret passages test passed")
    quit(0)
