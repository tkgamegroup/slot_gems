extends Control

const UiGem = preload("res://ui_gem.gd")

@onready var title_txt : RichTextLabel = $Title
@onready var slot : Control = $Control
@onready var gem_ui : UiGem = $Control/UiGem
@onready var img_open : TextureRect = $Control/Open
@onready var img_close : TextureRect = $Control/Close
@onready var particles1 : CPUParticles2D = $Control/CPUParticles2D
@onready var particles2 : CPUParticles2D = $Control/CPUParticles2D2
@onready var button = $Button

var gem : Gem = null
var type : String
var thing : String
var price : int = 0

func load_gem(_gem : Gem):
	if _gem:
		gem = _gem
		img_open.hide()
		img_close.show()
		gem_ui.update(gem)
		button.disabled = false

func unload_gem():
	if gem:
		var ui = Hand.add_gem(gem)
		ui.global_position = slot.get_global_rect().get_center()
		img_open.show()
		img_close.hide()
		gem_ui.reset()
		button.disabled = true
		gem = null

func setup(_type : String, _thing : String, _price : int):
	type = _type
	thing = _thing
	price = _price

func _ready() -> void:
	if thing != "":
		title_txt.text = "[url=%s]%s[/url] [color=cyan][url=%s]%s[/url][/color]" % [type, tr(type), thing, tr(thing)]
	else:
		title_txt.text = "[url=%s]%s[/url]" % [type, tr(type)]
	button.disabled = true
	button.text.text = "[img=24]res://images/coin.png[/img]%d" % price
	Drag.add_target("gem", slot, func(payload, ev : String, extra : Dictionary):
		if ev == "peek":
			img_open.modulate = Color(0.7, 0.7, 0.7, 1.0)
			img_close.modulate = Color(0.7, 0.7, 0.7, 1.0)
		elif ev == "peek_exited":
			img_open.modulate = Color(1.0, 1.0, 1.0, 1.0)
			img_close.modulate = Color(1.0, 1.0, 1.0, 1.0)
		else:
			if gem:
				unload_gem()
			load_gem(payload.gem)
			return true
		return false
	)
	slot.gui_input.connect(func(event : InputEvent):
		if event is InputEventMouseButton:
			if event.pressed && event.button_index == MOUSE_BUTTON_RIGHT:
				SSound.se_drag_item.play()
				unload_gem()
	)
	slot.mouse_entered.connect(func():
		if gem:
			SSound.se_select.play()
			STooltip.show(slot, 0, gem.get_tooltip())
	)
	slot.mouse_exited.connect(func():
		STooltip.close()
	)
	button.button.pressed.connect(func():
		if !gem || App.coins < price:
			App.status_bar_ui.coins_text.hint()
			return
		if type == "w_enchant":
			var es = Buff.find_all_typed(gem, Buff.Type.Enchant)
			if es.size() >= 2:
				SSound.se_error.play()
				App.banner_ui.show_tip(tr("wr_enchant_quantity_limit"), "", 1.0)
				return
		if type == "w_delete":
			if App.gems.size() - 1 < Board.curr_min_gem_num:
				SSound.se_error.play()
				App.banner_ui.show_tip(tr("wr_delete_gem_count_limit") % Board.curr_min_gem_num, "", 1.0)
				return
		
		button.disabled = true
		App.coins -= price
		SSound.se_coin.play()
		
		var tween = App.game_tweens.create_tween()
		tween.tween_interval(0.2)
		var sp : AnimatedSprite2D = null
		if type == "w_enchant":
			tween.tween_callback(func():
				particles1.emitting = true
			)
			tween.tween_interval(0.7)
			tween.tween_callback(func():
				SSound.se_enchant.play()
				particles2.emitting = true
			)
			tween.tween_interval(0.4)
		tween.tween_callback(func():
			if type == "w_enchant":
				if thing == "w_enchant_charming":
					App.enchant_gem(gem, "w_enchant_charming")
				elif thing == "w_enchant_sharp":
					App.enchant_gem(gem, "w_enchant_sharp")
				elif thing == "w_wild":
					var bid = Buff.create(gem, Buff.Type.ChangeColor, {"color":Gem.ColorWild}, Buff.Duration.Eternal)
					Buff.create(gem, Buff.Type.Enchant, {"type":"w_wild","bid":bid}, Buff.Duration.Eternal)
				elif thing == "w_omni":
					var bid = Buff.create(gem, Buff.Type.ChangeRune, {"rune":Gem.RuneOmni}, Buff.Duration.Eternal)
					Buff.create(gem, Buff.Type.Enchant, {"type":"w_omni","bid":bid}, Buff.Duration.Eternal)
			elif type == "w_delete":
				App.delete_gem(null, gem, gem_ui, "craft_slot")
				gem = null
				App.shop_ui.delete_price += App.shop_ui.delete_price_increase
			elif type == "w_duplicate":
				App.duplicate_gem(null, gem, gem_ui, "craft_slot")
		)
		if type == "w_enchant":
			tween.tween_interval(0.3)
		elif type == "w_delete":
			tween.tween_interval(0.7)
		elif type == "w_duplicate":
			tween.tween_interval(1.3)
		tween.tween_callback(func():
			unload_gem()
		)
		tween.tween_property(self, "modulate:a", 0.0, 0.2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART)
		tween.tween_callback(func():
			App.save_to_file()
			self.queue_free()
		)
	)

func _exit_tree() -> void:
	if gem:
		unload_gem()
	Drag.remove_target(slot)
