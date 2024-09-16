@tool
extends Area2D

@export var papers: int: set = set_papers
@export var paper_texture: Texture2D
@export var offset: Vector2: set = set_offset

signal all_sprites_placed()
signal all_papers_destroyed()

var _paper_texture: ImageTexture = ImageTexture.new()
var _paper_offsets: Array = []

var effect = preload("res://resources/particles/scenes/paper_falling.tscn")

var sprite: Sprite2D
var wf

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	randomize()
	_paper_offsets.append(randi() % 3 - 1)
	add_child(Sprite2D.new(), true)
	sprite = $Sprite2D
	wf = weakref(sprite)
	sprite.use_parent_material = true
	set_papers(papers)
	set_offset(offset)


func set_papers(amount: int) -> void:
	var prev = papers
	papers = max(amount, 1)
	var image = Image.new()
	if paper_texture and sprite:
		_paper_offsets.reverse()
		_paper_offsets.resize(papers)
		_paper_offsets.reverse()
		for i in range(_paper_offsets.size()):
			if _paper_offsets[i] == null:
				_paper_offsets[i] = clamp((_paper_offsets[i-1] if not i == 0 else 0) + randi() % 3 - 1, -1, 1)
		#for i in range(prev, papers):
			#_paper_offsets[i] = clamp(_paper_offsets[i-1] + randi() % 3 - 1, -1, 1)
		
		var data: Image = paper_texture.get_image()
		image = image.create(paper_texture.get_width() + 2, paper_texture.get_height() * papers, true, Image.FORMAT_RGBA8)
		
		if paper_texture.get_image().get_format() == Image.FORMAT_RGB8: data = _rgb8_to_rgba8(data)
		
		for i in range(papers):
			image.blend_rect(data, Rect2(Vector2.ZERO, paper_texture.get_size()), Vector2(_paper_offsets[i] + 1, paper_texture.get_height() * i))
		_paper_texture = _paper_texture.create_from_image(image)
		sprite.texture = _paper_texture
		sprite.position = Vector2(0, -_paper_texture.get_height() / 2.0)


func _rgb8_to_rgba8(image: Image) -> Image:
	var ret_data: PackedByteArray
	for i_pixel in range(0, image.get_data_size(), 3):
		ret_data.append(image.get_data()[i_pixel])
		ret_data.append(image.get_data()[i_pixel+1])
		ret_data.append(image.get_data()[i_pixel+2])
		ret_data.append(255)
	return Image.create_from_data(image.get_width(), image.get_height(), image.has_mipmaps(), Image.FORMAT_RGBA8, ret_data)


func set_offset(amount):
	offset = amount
	if sprite:
		sprite.offset = offset


func _destroy():
	for paper in range(papers - 1, -1, -1):
		var pos = Vector2(_paper_offsets[0], -paper_texture.get_height() * papers) + global_position
		set_papers(papers - 1)
		create_effect(pos, 1)
		await get_tree().create_timer(.01).timeout
	emit_signal("all_papers_destroyed")


func create_effect(pos: Vector2, amount: int) -> void:
	var e = effect.instantiate()
	e.amount = amount
	e.global_position = pos - get_parent().position
	get_parent().add_child(e)


func _on_body_entered(body: Node2D) -> void:
	_destroy()
	await self.all_papers_destroyed
	queue_free()


func _on_visibility_changed() -> void:
	$CollisionShape2D.disabled = not visible


func _on_all_papers_destroyed() -> void:
	pass
