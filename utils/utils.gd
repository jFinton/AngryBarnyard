class_name Utils


# static basically makes one instance of it made in the first load
# More so like a singleton but for functions
static func vec2_to_string(vec: Vector2) -> String:
	return "(%.1f, %.1f)" % [
		vec.x, vec.y
	]
