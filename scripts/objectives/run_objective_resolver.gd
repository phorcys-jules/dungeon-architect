class_name RunObjectiveResolver
extends RefCounted

enum Outcome { RUNNING, DUNGEON_VICTORY, DUNGEON_DEFEAT }

func resolve(chest: TreasureChestState, carrier_at_exit: bool, living_adventurers: int, waves_remaining: int) -> Outcome:
    if chest.is_carried() and carrier_at_exit:
        return Outcome.DUNGEON_DEFEAT
    if living_adventurers <= 0:
        return Outcome.DUNGEON_VICTORY
    if waves_remaining <= 0 and not chest.is_carried():
        return Outcome.DUNGEON_VICTORY
    return Outcome.RUNNING

func message(outcome: Outcome) -> String:
    match outcome:
        Outcome.DUNGEON_VICTORY:
            return "Le trésor est protégé : le maître du donjon remporte la run."
        Outcome.DUNGEON_DEFEAT:
            return "Un aventurier s'est échappé avec le trésor."
        _:
            return "L'invasion continue."
