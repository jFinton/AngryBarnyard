extends Area2D


@onready var splash_sound: AudioStreamPlayer2D = $SplashSound




func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group(GameManager.GROUP_ANIMAL):
		splash_sound.play()
