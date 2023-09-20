extends RigidBody2D


var _dead: bool = false
var _dragging: bool = false
var _released: bool = false
var _start: Vector2 = Vector2.ZERO
var _drag_start: Vector2 = Vector2.ZERO
var _dragged_vector: Vector2 = Vector2.ZERO
var _last_dragged_position: Vector2 = Vector2.ZERO
var _last_drag_amount: float = 0.0
var _fired_time: float = 0.0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_start = global_position


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	update_debug_label()


func update_debug_label() -> void:
	var s = "g_pos:%s\n" % [
		Utils.vec2_to_string(global_position)
	]
	s += "_dragging:%s _released:%s\n" % [
		_dragging,
		_released
	]
	s += "_start:%s _drag_start:%s\n" % [
		Utils.vec2_to_string(_start),
		Utils.vec2_to_string(_drag_start)
	]
	s += "_last_dragged_pos:%s _last_drag_amount:%.1f _fired_time:%.1f\n" % [
		Utils.vec2_to_string(_last_dragged_position),
		_last_drag_amount,
		_fired_time
	]
	s += "ang:%.1f linear:%s" % [
		angular_velocity,
		Utils.vec2_to_string(linear_velocity)
	]
	SignalManager.on_update_debug_label.emit(s) # Emits to Level


func grab_it() -> void:
	_dragging = true
	_drag_start = get_global_mouse_position()
	_last_dragged_position = _drag_start


func die() -> void:
	if _dead: return
	
	_dead = true
	SignalManager.on_animal_died.emit()
	queue_free()


func _on_screen_exited() -> void:
	die()


func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if _dragging or _released: return
	
	if event.is_action_pressed("drag"):
		grab_it()
