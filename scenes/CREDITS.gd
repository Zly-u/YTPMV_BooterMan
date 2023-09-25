extends Control

@onready var scroll: ScrollContainer = %ScrollContainer

var scroll_progress: float = 0.0
var total_scroll_progress: float = 0.0
var scroll_speed: float = 10.0
var wheel_scroll_speed: float = 5.0
var scroll_dir: int = 1

var scroll_pause: float = 2.0
var cur_scroll_pause: float = 2.0

var scroll_start: int = 40

var texts = [
	["Roskuro's carpet", null, null],
	["poskudo", null, null],
	["Azad Festifal", null, null],
	["Ter", null, null],
	["MUZPOOPER", null, null],
	["Kolificent", "https://cdn.discordapp.com/attachments/689528380219326472/1155815398458015765/gpvpgs.mp4", preload("res://fonts/Kolifination.ttf")],
	["SIlva Oruzie Kollam", null, null],
	["Dmitry udalov", null, null],
	["Nikita - moral support", "https://media.discordapp.net/attachments/696780456213086208/1155908155537104956/amud_hammed.png?width=605&height=910", null],
]
func _ready() -> void:
	for n in 10:
		var new_text: LinkButton = %Link_Presset.duplicate()
		new_text.text = ""
		%VBox_Scroll.add_child(new_text)
	
	for text in texts:
		var new_text: LinkButton = %Link_Presset.duplicate()
		new_text.text = text[0]
		if text[1]:
			new_text.uri = text[1]
		if text[2]:
			new_text.set("theme_override_fonts/font", text[2])
			new_text.set("theme_override_font_sizes/font_size", 12)
		%VBox_Scroll.add_child(new_text)
	
	for n in 10:
		var new_text: LinkButton = %Link_Presset.duplicate()
		new_text.text = ""
		%VBox_Scroll.add_child(new_text)
	
	total_scroll_progress = %VBox_Scroll.get_children().size()*15


var init_scroll: bool = false
func _process(delta: float) -> void:
	if !init_scroll:
		scroll.scroll_vertical = 69696
		total_scroll_progress = scroll.scroll_vertical
		scroll_progress = scroll_start
		scroll.scroll_vertical = scroll_start
		init_scroll = true
	
	
		
	if cur_scroll_pause > 0:
		cur_scroll_pause -= delta
		return
	
	if scroll.scroll_vertical == 0 and scroll_dir == -1:
		scroll_dir = 1
	
	if scroll.scroll_vertical == total_scroll_progress and scroll_dir == 1:
		scroll_dir = -1
	
	scroll_progress += scroll_speed * scroll_dir * delta
	scroll.scroll_vertical = scroll_progress


func _input(event: InputEvent) -> void:
	if !event is InputEventMouseButton: return
	cur_scroll_pause = scroll_pause
	
	if event.button_index == MOUSE_BUTTON_WHEEL_UP:
		scroll_progress = max(scroll_progress-wheel_scroll_speed, 0)
	if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
		scroll_progress = min(scroll_progress+wheel_scroll_speed, total_scroll_progress)
		
	scroll.scroll_vertical = scroll_progress


func _on_video_stream_player_finished() -> void:
	$VideoStreamPlayer.play()


func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/MENU.tscn")

