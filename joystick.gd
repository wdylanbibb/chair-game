extends Control


@export var max_length: float = 64

signal value_changed(value)
signal released(value)

@onready var line = $Line2D
@onready var panel = $Panel


var disabled : bool
var held : bool


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false
	line.points = PackedVector2Array([
		Vector2.ZERO,
		Vector2.ZERO,
	])


func _on_gui_input(event: InputEvent) -> void:
	_joystick_input(event, true)


func _input(event: InputEvent) -> void:
	if not disabled:
		if 'position' in event:
			if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
				visible = true
				position = event.position
		_joystick_input(event, false)


func _joystick_input(event: InputEvent, is_gui_input: bool):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				held = true
			else:
				visible = false
				held = false
				emit_signal("released", get_value())
				line.points[1] = Vector2.ZERO
	if event is InputEventMouseMotion:
		if held:
			if is_gui_input:
				set_end_point(event.position)
				emit_signal("value_changed", get_value())


func get_value():
	return (line.points[1] - line.points[0]) / max_length


func set_end_point(point: Vector2):
	line.points[1] = point.limit_length(max_length)
