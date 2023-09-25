extends Control

@onready var scroll: ScrollContainer = %ScrollContainer

var scroll_progress: float = 0.0
var total_scroll_progress: float = 0.0
var scroll_speed: float = 10.0
var wheel_scroll_speed: float = 5.0
var scroll_dir: int = 1

var scroll_pause: float = 2.0
var cur_scroll_pause: float = 2.0

var scroll_start: int = 25

var texts: Array = [
	{
		text = "Sladkiy Chel",
		links = [
			
		],
		font = null
	},
	{
		text = "Buterbrodik",
		links = [
			
		],
		font = null
	},
	{
		text = "Little_pixel_font",
		links = [
			"https://www.dafont.com/little-pixel.font"
		],
		font = {
			file = preload("res://fonts/little-pixel.ttf"),
			size = 5
		}
	},
	{
		text = "Roskuro's carpet",
		links = [
			
		],
		font = null
	},
	{
		text = "Azad Festifal",
		links = [],
		font = null
	},
	{
		text = "Quyu",
		links = [
			"https://cdn.discordapp.com/attachments/696780456213086208/1155908155537104956/amud_hammed.png"
		],
		font = null
	},
	{
		text = "Ter",
		links = [
			"https://media.discordapp.net/attachments/696317116466331709/1155602520912175214/boot_gun_asian.png?width=687&height=460"
		],
		font = null
	},
	{
		text = "MUZPOOPER",
		links = [
			
		],
		font = null
	},
	{
		text = "Kolificent",
		links = [
			"https://files.catbox.moe/gpvpgs.mp4"
		],
		font = {
			file = preload("res://fonts/Kolifination.ttf"),
			size = 12
		}
	},
	{
		text = "SIlva Oruzie Kollab",
		links = [],
		font = null
	},
	{
		text = "Dmitry udalov",
		links = [
			"https://cdn.discordapp.com/attachments/696780456213086208/1155910577315643472/Discord_4TlELSB0wE.png",
			"https://cdn.discordapp.com/attachments/696780456213086208/1155910614485581885/meanwhile_toilet.png"
		],
		font = null,
		sound = preload("res://sounds/credits/dmitry_udalov.mp3"),
	},
	{
		text = "Nikita - moral support",
		links = [
			"https://cdn.discordapp.com/attachments/689528380219326472/1155911862014189699/3nZEQlL1hP4.jpg"
		],
		font = null
	},
	{
		text = "Vadim",
		links = [
			"https://media.discordapp.net/attachments/689528380219326472/1079688057848090664/Discord_D6YMZgFBBY.gif",
			"https://files.catbox.moe/sugl37.mp4",
			"https://files.catbox.moe/180bbr.mp4",
		],
		font = null
	},
]
func _ready() -> void:
	generate_links()


var init_scroll: bool = false
func generate_links():
	for child in %VBox_Scroll.get_children():
		child.queue_free()
		
	for n in 7:
		var new_text: LinkButton_Better = %Link_Presset.duplicate()
		new_text.text = ""
		%VBox_Scroll.add_child(new_text)
	
	for text in texts:
		var new_text: LinkButton_Better = %Link_Presset.duplicate()
		new_text.text = text.text
		if text.links.size() != 0:
			new_text.uri = text.links.pick_random()
		if text.font:
			new_text.set("theme_override_fonts/font", text.font.file)
			new_text.set("theme_override_font_sizes/font_size", text.font.size)
		
		if text.has("sound"):
			new_text.data["sound"] = text.sound
		
		%VBox_Scroll.add_child(new_text)
	
	for n in 10:
		var new_text: LinkButton = %Link_Presset.duplicate()
		new_text.text = ""
		%VBox_Scroll.add_child(new_text)
	
	total_scroll_progress = %VBox_Scroll.get_children().size()*15


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
	
	scroll_progress = clamp(scroll_progress + scroll_speed * scroll_dir * delta, 0, total_scroll_progress)
	scroll.scroll_vertical = int(scroll_progress)


func _input(event: InputEvent) -> void:
	if !event is InputEventMouseButton: return
	
	if event.button_index == MOUSE_BUTTON_WHEEL_UP:
		cur_scroll_pause = scroll_pause
		scroll_progress = max(scroll_progress-wheel_scroll_speed, 0)
		scroll_dir = -1
	if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
		cur_scroll_pause = scroll_pause
		scroll_progress = min(scroll_progress+wheel_scroll_speed, total_scroll_progress)
		scroll_dir = 1
		
	scroll.scroll_vertical = int(scroll_progress)


func _on_video_stream_player_finished() -> void:
	$VideoStreamPlayer.play()


func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/MENU.tscn")



func _on_sprite_mouse_entered() -> void:
	%AnimatedSprite2D.play()


func _on_sprite_mouse_exited() -> void:
	%AnimatedSprite2D.pause()


func _on_link_presset_link_pressed(_self: LinkButton_Better) -> void:
	generate_links()
	if _self.data.has("sound"):
		%Sounds.stream = _self.data.sound
		%Sounds.play()
