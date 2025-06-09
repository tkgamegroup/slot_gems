extends Control

@onready var title_lb : RichTextLabel = $RichTextLabel
@onready var gem_ui = $Control/UiGem
@onready var img_open : TextureRect = $Control/Open
@onready var img_close : TextureRect = $Control/Close
@onready var enchant_button : Button = $Button

var gem : Gem = null
var cost : int = 0
var callback : Callable

func setup(title : String, tt_title : String, tt_content : String, button_text : String, _cost : int, cb : Callable):
	title_lb.text = title
	title_lb.mouse_entered.connect(func():
		SSound.sfx_select.play()
		STooltip.show([Pair.new(tt_title, tt_content)])
	)
	title_lb.mouse_exited.connect(func():
		STooltip.close()
	)
	enchant_button.text = "%s %dG" % [button_text, _cost]
	cost = _cost
	callback = cb
	enchant_button.pressed.connect(func():
		if gem && Game.coins >= cost:
			Game.coins -= cost
			callback.call()
	)
