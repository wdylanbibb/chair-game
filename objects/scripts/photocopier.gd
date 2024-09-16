extends StaticBody2D


@onready var player = $AnimationPlayer


var hits = 0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player.play("RESET")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_player_detector_body_entered(body: Node2D) -> void:
	hits += 1
	if hits < 3:
		if body.position.x < position.x:
			player.play("hit_left")
		else:
			player.play("hit_right")
	else:
		player.play("final_hit")
