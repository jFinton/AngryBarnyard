extends Node2D


var animal_scene: PackedScene = preload("res://Animal/animal.tscn")


@onready var debug_label: Label = $DebugLabel
@onready var animal_spawn: Marker2D = $AnimalSpawn


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalManager.on_update_debug_label.connect(on_update_debug_label)
	SignalManager.on_animal_died.connect(on_animal_died)
	on_animal_died()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func on_update_debug_label(text: String) -> void:
	debug_label.text = text


func on_animal_died() -> void:
	var animal = animal_scene.instantiate()
	animal.global_position = animal_spawn.global_position
	add_child(animal)
