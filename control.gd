extends Control

@onready var panel = $Panel
@onready var npc_name_label = $Panel/Label
@onready var dialogue_label = $Panel/Label2
@onready var npc_sprite = $Panel/Sprite2D

# variables
var original_position: Vector2
var original_size: Vector2
var slide_duration: float = 0.5
var expand_duration: float = 0.4
var typewriter_speed: float = 0.025
var current_text: String = ""
var text_index: int = 0
var is_typing: bool = false
var typing_timer: float = 0.0

# tweens and typewriter
var slide_tween: Tween
var expand_tween: Tween
var typewriter_timer: Timer

func _ready():
	original_position = panel.position
	original_size = panel.size
	
	var viewport_size = get_viewport().get_visible_rect().size
	var bottom_position = Vector2(original_position.x, viewport_size.y)
	
	panel.position = bottom_position
	panel.size.x = 0
	
	visible = false
	
	typewriter_timer = Timer.new()
	typewriter_timer.wait_time = typewriter_speed
	typewriter_timer.timeout.connect(_on_typewriter_tick)
	add_child(typewriter_timer)

func show_dialogue(npc_name: String, dialogue_text: String, npc_portrait: Texture2D = null):
	# setup dialogue
	npc_name_label.text = npc_name
	dialogue_label.text = dialogue_text
	dialogue_label.visible_ratio = 0.0
	current_text = dialogue_text
	text_index = 0
	
	if npc_portrait:
		npc_sprite.texture = npc_portrait
		npc_sprite.visible = true
	else:
		npc_sprite.visible = false
	
	visible = true
	slide_up()

func slide_up():
	if slide_tween:
		slide_tween.kill()
	slide_tween = create_tween()
	slide_tween.set_ease(Tween.EASE_OUT)
	slide_tween.set_trans(Tween.TRANS_BACK)
	slide_tween.tween_property(panel, "position", original_position, slide_duration)
	slide_tween.tween_callback(expand_width)

func expand_width():
	if expand_tween:
		expand_tween.kill()
	expand_tween = create_tween()
	expand_tween.set_ease(Tween.EASE_OUT)
	expand_tween.set_trans(Tween.TRANS_QUART)
	expand_tween.tween_property(panel, "size:x", original_size.x, expand_duration)
	expand_tween.tween_callback(start_typewriter)

func start_typewriter():
	is_typing = true
	text_index = 0
	dialogue_label.text = current_text
	dialogue_label.visible_ratio = 0.0
	typewriter_timer.start()

func _on_typewriter_tick():
	if text_index < current_text.length():
		text_index += 1
		dialogue_label.visible_ratio = float(text_index) / float(current_text.length())
	else:
		is_typing = false
		dialogue_label.visible_ratio = 1.0 # sanity check
		typewriter_timer.stop()

func skip_typewriter():
	if is_typing:
		is_typing = false
		typewriter_timer.stop()
		dialogue_label.visible_ratio = 1.0
		text_index = current_text.length()

func hide_dialogue():
	if expand_tween:
		expand_tween.kill()
	expand_tween = create_tween()
	expand_tween.set_ease(Tween.EASE_IN)
	expand_tween.set_trans(Tween.TRANS_QUART)
	expand_tween.tween_property(panel, "size:x", 0, expand_duration)
	expand_tween.tween_callback(slide_down)

func slide_down():
	if slide_tween:
		slide_tween.kill()
	slide_tween = create_tween()
	slide_tween.set_ease(Tween.EASE_IN)
	slide_tween.set_trans(Tween.TRANS_BACK)
	var viewport_size = get_viewport().get_visible_rect().size
	var bottom_position = Vector2(original_position.x, viewport_size.y)
	slide_tween.tween_property(panel, "position", bottom_position, slide_duration)
	slide_tween.tween_callback(func(): visible = false)

func _input(event):
	if not visible:
		return
	if event.is_action_pressed("ui_accept"):
		if is_typing:
			skip_typewriter()
		else:
			hide_dialogue()

func set_typewriter_speed(speed: float):
	typewriter_speed = speed
	typewriter_timer.wait_time = speed

func set_expand_duration(duration: float):
	expand_duration = duration

func set_slide_duration(duration: float):
	slide_duration = duration
