extends Node2D


@onready var debug_label: Label = $DebugLabel


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalManager.on_update_debug_label.connect(on_update_debug_label)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func on_update_debug_label(text: String) -> void:
	debug_label.text = text
