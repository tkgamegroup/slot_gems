extends PanelContainer

@export var title_txt : Label
@export var desc_txt : RichTextLabel
@export var passed_mark : TextureRect
@export var current_mark : Control

var round : int = -1

func setup(_round : int):
	round = _round

func _ready() -> void:
	title_txt.text = tr("ui_game_round") % round
	desc_txt.text = "%d" % G.get_round_score(round)
	if round < G.current_round:
		self.modulate = Color(0.7, 0.7, 0.7, 1.0)
		passed_mark.show()
	elif round == G.current_round:
		if G.shop_ui.visible:
			self.modulate = Color(0.7, 0.7, 0.7, 1.0)
			passed_mark.show()
		else:
			current_mark.show()
