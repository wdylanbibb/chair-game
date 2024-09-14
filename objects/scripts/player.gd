@tool
extends RigidBody2D


@onready var sprite = $Sprite2D
@onready var _sprite_position = sprite.position
@onready var _sprite_rotation = sprite.rotation
@onready var collision = $CollisionShape2D
@onready var _collision_rotation = collision.rotation
@onready var line = $Line2D
@onready var _line_position = line.position

@onready var joystick = $CanvasLayer/Joystick
@onready var canvas_layer = $CanvasLayer

@export var impulse_strength: float = 400
@export var max_speed: float = 400


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	line.points[1] = Vector2.ZERO


func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		if not sprite:
			sprite = $Sprite2D
			_sprite_position = sprite.position
		if not collision: collision = $CollisionShape2D
		if not line:
			line = $Line2D
			_line_position = line.position
	sprite.rotation = -rotation
	var a = snapped(rotation, PI/4) / (PI/4)
	a = wrapi(int(a), 0, 8)
	sprite.frame = a
	collision.rotation = PI/2 - rotation
	sprite.position = _sprite_position.rotated(-rotation)
	if not Engine.is_editor_hint():
		if joystick.held:
			line.position = _line_position.rotated(joystick.get_value().angle() + PI/2 - rotation)
			line.points[1] = joystick.get_value() * 15
	line.rotation = -rotation


func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	linear_velocity = linear_velocity.limit_length(max_speed)


func _on_joystick_released(value: Variant) -> void:
	line.points[1] = Vector2.ZERO
	apply_central_impulse(value * impulse_strength)
	Engine.time_scale = 1


func _on_joystick_value_changed(value: Variant) -> void:
	Engine.time_scale = 0.1
