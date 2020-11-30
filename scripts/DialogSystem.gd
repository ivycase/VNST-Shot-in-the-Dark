extends Control

signal next

onready var choicebox = get_node("Choice Box")
onready var shoot_sound = get_node("Shoot")
onready var timer = get_node("Timer")
onready var tween = get_node("Tween")
onready var white_screen = get_node("White Screen")

var key
var target
var pressed
	
func _input(event):
	var boost_amt = 4
	if event.is_action_pressed("ui_accept"):
		emit_signal("next")
		timer.wait_time /= boost_amt
		pressed = true
	if pressed and event.is_action_released("ui_accept"):
		timer.wait_time *= boost_amt
	if event.is_action_pressed("shoot"):
		shoot()
		
func shoot():
	var shot = target
	shoot_sound.play()
	
	if shot:
		shot.die()
	
	var flash_time = 1
	white_screen.show()
	tween.interpolate_property(white_screen, "color", Color(1, 1, 1, 1), Color(1, 1, 1, 0), flash_time, Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween.start()
	yield(tween, "tween_completed")
		
func parse_script(script):
	var lines = script.strip_edges().split("\n")
	
	var dialogue = []
	for l in lines:
		var lineinfo = l.strip_edges().split("::")
		var actor = key[lineinfo[0].strip_edges()]
		var text = lineinfo[1].strip_edges()
		dialogue.append([actor, text])
	return dialogue
	
func end():
	pass
	
func fade_in():
	white_screen.show()
	tween.interpolate_property(white_screen, "color", Color(0, 0, 0, 1), Color(0, 0, 0, 0), 2)
	tween.start()

func fade_out():
	white_screen.show()
	tween.interpolate_property(white_screen, "color", Color(0, 0, 0, 0), Color(0, 0, 0, 1), 2)
	tween.start()
	
func direct_scene(intro, scripts):
	fade_in()
	yield(play_dialogue(intro), "completed")
	while choicebox.any_enabled():
		choicebox.show()
		yield(choicebox, "choice")
			
		var choice_index = choicebox.get_choice()
		choicebox.disable(choice_index)
		choicebox.hide()
			
		var script = parse_script(scripts[choice_index])
		yield(play_dialogue(script), "completed")
	end()

func play_dialogue(dialogue):
	#dialogue e.g. [[sphere, "Hello."], [narrator, "Wow."]]
	for lineinfo in dialogue:
		var actor = lineinfo[0]
		var text = lineinfo[1]
		actor.enter_limelight()
		yield(actor.act(text), "completed")
		yield(self, "next")
		actor.exit_limelight()
