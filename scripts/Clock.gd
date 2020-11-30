extends "res://scripts/Actor.gd"

var mouse_over

func _onready():
	hide()
	body.connect("mouse_entered", self, "_on_mouse_enter")
	body.connect("mouse_exited", self, "_on_mouse_exit")
	
func _on_mouse_enter():
	mouse_over = true
	if shootable:
		body.get_material().set_shader_param("enabled", true)
		get_parent().target = self
	

func _on_mouse_exit():
	mouse_over = false
	if shootable:
		body.get_material().set_shader_param("enabled", false)
		get_parent().target = null
		
func act(line):
	print(line)
	voice.play()
	timer.start()
	yield(timer, "timeout")
	
func enter_limelight():
	show()

func exit_limelight():
	pass
