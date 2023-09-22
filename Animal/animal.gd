extends RigidBody2D


@onready var stretch_sound: AudioStreamPlayer2D = $StretchSound
@onready var launch_sound: AudioStreamPlayer2D = $LaunchSound
@onready var collision_sound: AudioStreamPlayer2D = $CollisionSound


const DRAG_LIM_MIN: Vector2 = Vector2(-60, 0)
const DRAG_LIM_MAX: Vector2 = Vector2(0, 60)
const IMPULSE_MULT: float = 16.0
const FIRE_DELAY: float = 0.25
const STOPPED: float = 0.1


var _dead: bool = false
var _stretch_has_played: bool = false
var _dragging: bool = false
var _released: bool = false
var _start: Vector2 = Vector2.ZERO
var _drag_start: Vector2 = Vector2.ZERO
var _dragged_vector: Vector2 = Vector2.ZERO
var _last_dragged_position: Vector2 = Vector2.ZERO
var _last_drag_amount: float = 0.0
var _fired_time: float = 0.0
var _last_collision_count: int = 0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_start = global_position


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	update_debug_label()
	
	if _released:
		_fired_time += delta
		if _fired_time > FIRE_DELAY:
			play_collision()
			check_on_target()
	else:
		if !_dragging:
			return
		else:
			if Input.is_action_just_released("drag"):
				release_it()
			else:
				drag_it()
	


func update_debug_label() -> void:
	var s = "g_pos:%s contacts: %s\n" % [
		Utils.vec2_to_string(global_position),
		get_contact_count()
	]
	s += "_dragging:%s _released:%s\n" % [
		_dragging,
		_released
	]
	s += "_start:%s _drag_start:%s _dragged_vector:%s\n" % [
		Utils.vec2_to_string(_start),
		Utils.vec2_to_string(_drag_start),
		Utils.vec2_to_string(_dragged_vector)
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


func stopped_rolling() -> bool:
	if get_contact_count() > 0:
		if abs(linear_velocity.y) < STOPPED and abs(angular_velocity) < STOPPED:
			return true
	return false


func check_on_target() -> void:
	if !stopped_rolling(): return
	
	var cb = get_colliding_bodies()
	if cb.size() == 0: return
	
	if cb[0].is_in_group(GameManager.GROUP_CUP):
		cb[0].die()
		die()

func play_collision() -> void:
	if _last_collision_count == 0 and get_contact_count() > 0 and !collision_sound.playing:
		collision_sound.play()
	_last_collision_count = get_contact_count()


func grab_it() -> void:
	_dragging = true
	_drag_start = get_global_mouse_position()
	_last_dragged_position = _drag_start


func drag_it() -> void:
	var gmp = get_global_mouse_position()
	
	_last_drag_amount = (_last_dragged_position - gmp).length()
	_last_dragged_position = gmp
	
	if _last_drag_amount > 0 and !_stretch_has_played:
		stretch_sound.play()
		_stretch_has_played = true
	
	_dragged_vector = gmp - _drag_start
	_dragged_vector.x = clampf(_dragged_vector.x, DRAG_LIM_MIN.x, DRAG_LIM_MAX.x)
	_dragged_vector.y = clampf(_dragged_vector.y, DRAG_LIM_MIN.y, DRAG_LIM_MAX.y)
	global_position = _start + _dragged_vector


func release_it() -> void:
	_dragging = false
	_released = true
	freeze = false
	apply_central_impulse(get_impulse())
	stretch_sound.stop()
	launch_sound.play()


func get_impulse() -> Vector2:
	return _dragged_vector * -1 * IMPULSE_MULT


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
