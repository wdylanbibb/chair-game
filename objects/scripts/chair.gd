@tool
extends RigidBody2D


@onready var sprite = $Sprite2D
@onready var _sprite_position = sprite.position
@onready var collision = $CollisionShape2D


# warning-ignore:unused_argument
func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		if not sprite:
			sprite = $Sprite2D
			_sprite_position = sprite.position
		if not collision:
			collision = $CollisionShape2D
	sprite.rotation = -rotation
	var a = snapped(rotation, PI/4) / (PI/4)
	a = wrapi(int(a), 0, 8)
	sprite.frame = a
	collision.rotation = PI/2 - rotation
	sprite.position = _sprite_position.rotated(-rotation)
