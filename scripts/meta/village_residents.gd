class_name VillageResidents
extends RefCounted

const RESIDENTS := {
	"contract_steward": {"name": "Morga", "role": "Intendante des contrats", "min_reputation": 0, "min_contracts": 0, "service": "contracts", "line": "Un bon contrat commence par un acompte lisible."},
	"goblin_smith": {"name": "Brak", "role": "Forgeron gobelin", "min_reputation": 5, "min_contracts": 1, "service": "forge", "line": "Je répare les pièges. Les aventuriers, beaucoup moins."},
	"kobold_engineer": {"name": "Klik", "role": "Ingénieur kobold", "min_reputation": 15, "min_contracts": 3, "service": "blueprints", "line": "Deux mesures, trois calculs, un effondrement contrôlé."},
	"bone_archivist": {"name": "Maître Ossec", "role": "Archiviste squelette", "min_reputation": 25, "min_contracts": 5, "service": "archives", "line": "J’ai classé vos succès par ordre d’importance posthume."},
	"bog_alchemist": {"name": "Vespa", "role": "Alchimiste du marais", "min_reputation": 40, "min_contracts": 8, "service": "laboratory", "line": "Cette mutation est parfaitement sûre. Pour moi."},
	"black_marketeer": {"name": "Chiffon", "role": "Fournisseur clandestin", "min_reputation": 60, "min_contracts": 12, "service": "black_market", "line": "La provenance est secrète. La malédiction, contractuelle."},
}

var unlocked: Array[String] = []

func refresh(reputation: int, completed_contracts: int) -> Array[Dictionary]:
	for resident_id in RESIDENTS:
		var resident: Dictionary = RESIDENTS[resident_id]
		if reputation >= int(resident.min_reputation) and completed_contracts >= int(resident.min_contracts):
			if not unlocked.has(resident_id):
				unlocked.append(resident_id)
	return active_residents()

func active_residents() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for resident_id in unlocked:
		var resident: Dictionary = RESIDENTS[resident_id].duplicate(true)
		resident["id"] = resident_id
		resident["animation"] = "ambient_%s" % resident.service
		result.append(resident)
	result.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return String(a.id) < String(b.id))
	return result

func to_dict() -> Dictionary:
	return {"unlocked": unlocked.duplicate()}

func from_dict(data: Dictionary) -> void:
	unlocked.clear()
	for resident_id in data.get("unlocked", []):
		if RESIDENTS.has(String(resident_id)):
			unlocked.append(String(resident_id))
