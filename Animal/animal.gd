extends RigidBody2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	update_debug_label()


func update_debug_label() -> void:
	var s = "g_pos:%s\n" % [
		Utils.vec2_to_string(global_position)
	]
	s += "ang:%.1f linear:%s" % [
		angular_velocity,
		Utils.vec2_to_string(linear_velocity)
	]
	SignalManager.on_update_debug_label.emit(s)
