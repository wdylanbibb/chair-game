extends GPUParticles2D


func _on_finished() -> void:
	print("finished")
	queue_free()
