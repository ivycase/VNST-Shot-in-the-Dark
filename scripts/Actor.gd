extends Node2D

export(Color, RGB) var textcolor
export(bool) var is_right_aligned

onready var body = get_node("body")
onready var nonbody = get_node("nonbody")
onready var text_box = get_node("../Text Box")
onready var voice = get_node("voice")
onready var timer = get_node("../Timer")

var anim
var text
var hiding

func _ready():
	if nonbody:
		text = nonbody.get_node("text")
	if body:
		text = text_box.get_node("text")
		anim = body.get_node("anim")
		body.connect("mouse_entered", self, "_on_mouse_enter")
		body.connect("mouse_exited", self, "_on_mouse_exit")
		
	exit_limelight()
	
func _on_mouse_enter():
	if hiding:
		anim.modulate = Color(1, 1, 1)
		anim.playing = true
	anim.get_material().set_shader_param("enabled", true)
	get_parent().target = self
	

func _on_mouse_exit():
	if hiding:
		anim.modulate = Color(0, 0, 0)
		anim.playing = false
	anim.get_material().set_shader_param("enabled", false)
	get_parent().target = null
	
func act(line):
	if is_right_aligned:
		text.bbcode_text = "[right][color=#{hexcode}]{line}[/color][/right]".format({"hexcode": textcolor.to_html(), "line": line})
	else:
		text.bbcode_text = "[color=#{hexcode}]{line}[/color]".format({"hexcode": textcolor.to_html(), "line": line})
	
	text.percent_visible = 0
	for letter in line:
		text.percent_visible += 1.0 / len(line)
		if letter != " ":
			voice.play()
			timer.start()
			yield(timer, "timeout")
	text.percent_visible = 1

func die():
	print("dead.")

func enter_limelight():
	if nonbody:
		show()
	if body:
		text_box.show()
		anim.modulate = Color(1, 1, 1)
		anim.playing = true
		hiding = false
	
func exit_limelight():
	if nonbody:
		hide()
	if anim:
		text_box.hide()
		anim.modulate = Color(0, 0, 0)
		anim.playing = false
		hiding = true
