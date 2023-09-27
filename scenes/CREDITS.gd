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
		font = null,
		sounds = [
			preload("res://sounds/credits/chel_deti.mp3"),
			preload("res://sounds/credits/ha-001.mp3"),
			preload("res://sounds/credits/ha-002.mp3"),
			preload("res://sounds/credits/ha-003.mp3"),
			preload("res://sounds/credits/ha-004.mp3"),
			preload("res://sounds/credits/ha-005.mp3"),
			preload("res://sounds/credits/ha-006.mp3"),
			preload("res://sounds/credits/ha-007.mp3"),
			preload("res://sounds/credits/ha-008.mp3"),
		]
	},
	{
		text = "Buterbrodik",
		links = [
			
		],
		font = null
	},
	{
		text = "Little-pixel  font",
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
			"https://files.catbox.moe/acay43.mp4",
		],
		font = null
	},
	{
		text = "Amurskiy Supchik",
		links = [
			"https://youtu.be/a68m9yQN9Pk?si=r1wIZ_Vjc5fJ9zcS&t=2",
			"https://www.youtube.com/watch?v=8D4MlJDoi9w",
		],
		font = null
	},
	{
		text = "Azad Festifal",
		links = [
			"https://www.youtube.com/watch?v=PhaXVAxI91s&t=266s",
			"https://cdn.discordapp.com/attachments/850104634197409902/993141384540327976/azad_in_govai.jpg?ex=6514297d&is=6512d7fd&hm=a53e6797cd4048c15022dbfa7999de9ebcdbc0b62719748f899c9be4e638125c&",
			
		],
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
			"https://media.discordapp.net/attachments/696317116466331709/1155602520912175214/boot_gun_asian.png?width=687&height=460",
			"https://cdn.discordapp.com/attachments/850104634197409902/1070660841583673444/1675335798.jpg?ex=65140c1c&is=6512ba9c&hm=895bfc93d05180e1397d204d5b8321bc475aed59377a5b4574c3352419dc7d43&",
		],
		font = null
	},
	{
		text = "MUZPOOPER",
		links = [
			"https://files.catbox.moe/2bezud.mp4",
			"https://www.youtube.com/watch?v=2XdljcaPBwA",
			"https://www.youtube.com/watch?v=X8s88Iqi724",
			"https://www.youtube.com/watch?v=Iz9tqL5AXqE",
		],
		font = null
	},
	{
		text = "Kolificent",
		links = [
			"https://files.catbox.moe/gpvpgs.mp4",
			"https://files.catbox.moe/n5y55f.mp4",
			"https://www.youtube.com/watch?v=Y0bSLhJiZVM",
			"https://files.catbox.moe/l9c300.mp4"
		],
		font = {
			file = preload("res://fonts/Kolifination.ttf"),
			size = 12
		},
		sounds = [
			preload("res://sounds/credits/pfff.mp3"),
		]
	},
	{
		text = "SIlva Oruzie Kollab",
		links = [
			"https://www.youtube.com/channel/UC2tXKVSMbfr7PvRigvqjbvw"
		],
		font = null
	},
	{
		text = "Dmitry udalov",
		links = [
			"https://t.me/udalov_ytpmv_telegram",
			"https://cdn.discordapp.com/attachments/696780456213086208/1155910577315643472/Discord_4TlELSB0wE.png",
			"https://files.catbox.moe/rh6pau.mp4",
			"https://files.catbox.moe/n19c7e.mp4",
			"https://cdn.discordapp.com/attachments/850104634197409902/1029341877222260826/FaceApp_1665484609736.jpg?ex=651405d3&is=6512b453&hm=9dab78834b6eb4d55c59d8f7466cb62a6ff7b2f43bf40add3178bba94a322462&",
			"https://www.youtube.com/watch?v=X8s88Iqi724",
		],
		font = null,
		sounds = [
			preload("res://sounds/credits/dmitry_udalov.mp3")
		],
	},
	{
		text = "Nikita - moral support",
		links = [
			"https://cdn.discordapp.com/attachments/689528380219326472/1155911862014189699/3nZEQlL1hP4.jpg",
			"https://files.catbox.moe/3mfyx1.mp4",
			"https://files.catbox.moe/kfrjs7.mp4",
		],
		font = null
	},
	{
		text = "Vadim",
		links = [
			"https://files.catbox.moe/sugl37.mp4",
			"https://files.catbox.moe/180bbr.mp4",
			"https://files.catbox.moe/aesxmn.mp4",
		],
		font = null
	},
	{
		text = "Baursach",
		links = [
			"https://www.youtube.com/watch?v=sUijxvKjBeU",
			"https://cdn.discordapp.com/attachments/850104634197409902/1089257599410643154/caption.jpg?ex=65147731&is=651325b1&hm=9f133892e4e2ee3507dfc65e3798239036e25934f913bc1825e5dea915479e66&",
			"https://files.catbox.moe/m6zb9n.mp4",
		],
		font = null
	},
	{
		text = "kshishtovskiy",
		links = [
			"https://files.catbox.moe/rwgt59.mp4",
		],
		font = null
	},
	{
		text = "Kimshumitsu",
		links = [
			"https://cdn.discordapp.com/attachments/850104634197409902/1095787603195875359/Discord_HTFlyElFyh-1.gif?ex=65147dbb&is=65132c3b&hm=53891a53e3f301f2c8787cc81778b377e07491628860e060f834924fc4dbf793&",
			"https://cdn.discordapp.com/attachments/850104634197409902/1095658657192091678/image.png?ex=651405a4&is=6512b424&hm=a3cb430394b5da079a17a8c48d923a8c305f84640300e4aeab4e2becbd3f2dbb&",
		]
	},
	{
		text = "Nagashnik",
		links = [
			"https://cdn.discordapp.com/attachments/850104634197409902/1050255332703744090/1670470683.jpg?ex=65144cc0&is=6512fb40&hm=45679e5dcba38fc1fcb293575a07fb7a9852cfa06b4973dfb9eb547ece3549b2&",
			"https://files.catbox.moe/vdicox.mp4",
			"https://cdn.discordapp.com/attachments/850104634197409902/975129166250901585/Discord_fdCjLkQ7A855.png?ex=6513e48e&is=6512930e&hm=7918365986310871749fe1d573ccdad564bf31238eb6300a82d095d5f07c2d03&",
		]
	},
	{
		text = "hamichok",
		links = [
			"https://cdn.discordapp.com/attachments/850104634197409902/1043159160805675078/image.png?ex=6514312c&is=6512dfac&hm=dd2692e2395b2294362b334d17848fb8d9c849f88143eb734f55b582646f5ab6&",
			"https://www.youtube.com/watch?v=NPxH1Jtethg",
		]
	},
	{
		text = "Nagashizar",
		links = [
			"https://files.catbox.moe/63rybw.mp4",
		]
	},
	{
		text = "Pyotr Obamov",
		links = [
			"https://files.catbox.moe/g4cewp.mp4"
		]
	},
	{
		text = "sergey",
		links = [
			"https://files.catbox.moe/hkoknr.mp4"
		]
	},
	{
		text = "Gena",
		links = [
			"https://files.catbox.moe/yl86y6.mp4",
			"https://files.catbox.moe/jydd17.mp4",
			"https://files.catbox.moe/td48l4.mp4",
		]
	},
	{
		text = "Reaper",
		links = [
			"https://www.reaper.fm/",
			"https://files.catbox.moe/lexhnu.mp4",
		]
	},
	{
		text = "Jazz",
		links = [
			"https://files.catbox.moe/hz27ov.mp4",
			"https://files.catbox.moe/w8mu3f.mp4"
		]
	},
	{
		text = "Pac-man",
		links = [
			"https://files.catbox.moe/f8zs67.mp4"
		]
	},
	{
		text = "CatFather VST",
		links = [
			"https://files.catbox.moe/b553qb.mp4"
		]
	},
	{
		text = "Herobrina",
		links = [
			"https://files.catbox.moe/ihi7nk.mp4",
			"https://files.catbox.moe/agugum.mp4",
			"https://files.catbox.moe/sso5nk.mp4"
		]
	},
	{
		text = "uza",
		links = [
			"https://files.catbox.moe/3wasgh.mp4",
			"https://files.catbox.moe/5flcn8.mp4"
		]
	},
	{
		text = "discord",
		links = [
			"https://files.catbox.moe/57f96j.mp4"
		]
	},
	{
		text = "Hleb",
		links = [
			"https://files.catbox.moe/l8kvea.mp4",
		]
	}
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
		
		new_text.data = text
		if text.get("font", null):
			if text.font.has("file"):
				new_text.set("theme_override_fonts/font", text.font.file)
			new_text.set("theme_override_font_sizes/font_size", text.font.get("size", 16))
		
		%VBox_Scroll.add_child(new_text)
	
	for n in 10:
		var new_text: LinkButton = %Link_Presset.duplicate()
		new_text.text = ""
		%VBox_Scroll.add_child(new_text)
	
	total_scroll_progress = %VBox_Scroll.get_children().size()*15

var buter_text_pos: Vector2
func _process(delta: float) -> void:
	if !init_scroll:
		scroll.scroll_vertical = 69696
		total_scroll_progress = scroll.scroll_vertical
		scroll_progress = scroll_start
		scroll.scroll_vertical = scroll_start
		init_scroll = true
	
	if %CPUParticles2D.emitting:
		%CPUParticles2D.position.x = buter_text_pos.x
		%CPUParticles2D.position.y = buter_text_pos.y-scroll_progress+scroll_start
		
		if scroll_start-scroll_progress+25 <= 0:
			%CPUParticles2D.emitting = false
	
	
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
	if _self.data.links.size() != 0:
		OS.shell_open(_self.data.links.pick_random())

	if _self.data.has("sounds"):
		%Sounds.stream = _self.data.sounds.pick_random()
		%Sounds.play()
	
	if _self.data.text == "Buterbrodik":
		%CPUParticles2D.emitting = true
		buter_text_pos = _self.global_position
		buter_text_pos.y += scroll_progress-scroll_start
