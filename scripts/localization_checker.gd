class_name LocalizationChecker
extends RefCounted

# Compares base keys to another locale and returns missing keys
func missing_keys(base: Dictionary, other: Dictionary) -> Array:
	var missing := []
	for k in base.keys():
		if not other.has(k):
			missing.append(k)
	return missing
