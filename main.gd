extends Node2D

@onready var textbox = $CanvasLayer/Control

func _ready():
	await get_tree().create_timer(2.0).timeout
	show_npc_dialogue()

func show_npc_dialogue():
	var npc_portrait = preload("res://.godot/imported/reina-open.png-d3f0943fd2bfcae70e318f9c47d6bdcb.ctex")
	
	textbox.show_dialogue(
		"Reina",
		"wow hi ! ok test text to TYPE OUT. lmao ... ok!! hi hi hi hi hello hi *explodes* yipee !!! amazing :3 ^__^",
		npc_portrait
	)

# example usage 1
func _on_npc_interact():
	var portrait = load("res://portraits/example.png")
	textbox.show_dialogue("Example", "Example Text", portrait)

# example usage 2
func _on_system_message():
	textbox.show_dialogue("System", "Game saved successfully!", null)
