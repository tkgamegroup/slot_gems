extends Control

@export var layout : BoxContainer
@export var shop_icon : Control
@export var shop_select : Control
@export var chest_icon : Control
@export var chest_select : Control

var round : int

func setup(_round : int):
	round = _round

func _ready() -> void:
	shop_icon.mouse_entered.connect(func():
		STooltip.show(shop_icon, 0, [Pair.new(tr("ui_shop"), "")])
	)
	shop_icon.mouse_exited.connect(func():
		STooltip.close()
	)
	if round < G.current_round:
		self.modulate = Color(0.7, 0.7, 0.7, 1.0)
	elif round == G.current_round:
		if G.shop_ui.visible:
			shop_select.show()
	if round % 6 == 0:
		layout.vertical = true
	if G.treasure_arrive_rounds.has(round):
		chest_icon.show()
		chest_icon.mouse_entered.connect(func():
			STooltip.show(chest_icon, 0, [Pair.new(tr("ui_chest"), tr("tt_chest%d_desc") % (int(round / 6) + 1))])
		)
		chest_icon.mouse_exited.connect(func():
			STooltip.close()
		)
