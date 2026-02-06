extends Control

const UiGem = preload("res://ui_gem.gd")
const UiSlot = preload("res://ui_gem_slot.gd")

@onready var title_txt : RichTextLabel = $Title
@onready var slot : UiSlot = $Slot
@onready var button = $MarginContainer/Button

var type : String
var thing : String
var price : int = 0

var disabled : bool = false:
	set(v):
		disabled = v
		if v:
			button.disabled = true
		else:
			if slot.gem:
				button.disabled = false
		slot.disabled = v

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
	button.text.text = "[img]res://images/coin.png[/img]%d" % price
	slot.on_load.connect(func(gem : Gem):
		button.disabled = false
	)
	slot.on_unload.connect(func(gem : Gem):
		var ui = Hand.add_gem(gem)
		ui.global_position = slot.get_global_rect().get_center()
		button.disabled = true
	)
	button.button.pressed.connect(func():
		if !slot.gem:
			return
		if G.coins < price:
			G.status_bar_ui.coins_text.hint()
			return
		if type == "w_enchant":
			var es = Buff.find_all_typed(slot.gem, Buff.Type.Enchant)
			if es.size() >= 2:
				SSound.se_error.play()
				G.banner_ui.show_tip(tr("wr_enchant_quantity_limit"), "", 1.0)
				return
		if type == "w_delete":
			if G.gems.size() - 1 < Board.curr_min_gem_num:
				SSound.se_error.play()
				G.banner_ui.show_tip(tr("wr_delete_gem_count_limit") % Board.curr_min_gem_num, "", 1.0)
				return
		
		G.shop_ui.disabled = true
		G.coins -= price
		SSound.se_coin.play()
		
		var tween = G.game_tweens.create_tween()
		tween.tween_interval(0.2)
		var sp : AnimatedSprite2D = null
		if type == "w_enchant":
			tween.tween_callback(func():
				slot.particles1.emitting = true
			)
			tween.tween_interval(0.7)
			tween.tween_callback(func():
				SSound.se_enchant.play()
				slot.particles2.emitting = true
			)
			tween.tween_interval(0.4)
		tween.tween_callback(func():
			if type == "w_enchant":
				if thing == "w_enchant_charming":
					G.enchant_gem(slot.gem, "w_enchant_charming")
				elif thing == "w_enchant_sharp":
					G.enchant_gem(slot.gem, "w_enchant_sharp")
				elif thing == "w_wild":
					var bid = Buff.create(slot.gem, Buff.Type.ChangeColor, {"color":Gem.ColorWild}, Buff.Duration.Eternal)
					Buff.create(slot.gem, Buff.Type.Enchant, {"type":"w_wild","bid":bid}, Buff.Duration.Eternal)
				elif thing == "w_omni":
					var bid = Buff.create(slot.gem, Buff.Type.ChangeRune, {"rune":Gem.RuneOmni}, Buff.Duration.Eternal)
					Buff.create(slot.gem, Buff.Type.Enchant, {"type":"w_omni","bid":bid}, Buff.Duration.Eternal)
			elif type == "w_delete":
				G.delete_gem(null, slot.gem, slot.gem_ui, "craft_slot")
				slot.gem = null
				G.shop_ui.delete_price += G.shop_ui.delete_price_increase
			elif type == "w_duplicate":
				G.duplicate_gem(null, slot.gem, slot.gem_ui, "craft_slot")
		)
		if type == "w_enchant":
			tween.tween_interval(0.3)
		elif type == "w_delete":
			tween.tween_interval(0.7)
		elif type == "w_duplicate":
			tween.tween_interval(1.3)
		tween.tween_callback(func():
			slot.unload_gem()
		)
		tween.tween_property(self, "modulate:a", 0.0, 0.2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART)
		tween.tween_callback(func():
			G.shop_ui.disabled = false
			G.save_to_file()
			self.queue_free()
		)
	)
