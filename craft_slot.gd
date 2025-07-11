extends Control

const UiGem = preload("res://ui_gem.gd")
const ShopButton = preload("res://shop_button.gd")

@onready var type_txt : Label = $HBoxContainer/Label
@onready var thing_txt : RichTextLabel = $HBoxContainer/RichTextLabel
@onready var socket_sp_ctrl : Control = $HBoxContainer/Control
@onready var socket_sp : AnimatedSprite2D = $HBoxContainer/Control/SocketSP
@onready var slot : Control = $Control
@onready var gem_ui : UiGem = $Control/UiGem
@onready var img_open : TextureRect = $Control/Open
@onready var img_close : TextureRect = $Control/Close
@onready var particles1 : CPUParticles2D = $Control/CPUParticles2D
@onready var particles2 : CPUParticles2D = $Control/CPUParticles2D2
@onready var button : ShopButton = $ShopButton

var gem : Gem = null
var type : String
var thing
var price : int = 0

func load_gem(_gem : Gem):
	if _gem:
		gem = _gem
		img_open.hide()
		img_close.show()
		gem_ui.set_image(gem.type, gem.rune, gem.bound_item.image_id if gem.bound_item else 0)
		button.button.disabled = false

func unload_gem():
	if gem:
		Hand.get_gem_from(gem, slot.get_global_rect().get_center())
		img_open.show()
		img_close.hide()
		gem_ui.set_image(0, 0, 0)
		button.button.disabled = true
		gem = null

func setup(_type : String, _thing, _price : int):
	type = _type
	thing = _thing
	price = _price

func _ready() -> void:
	type_txt.text = tr(type)
	type_txt.mouse_entered.connect(func():
		SSound.se_select.play()
		STooltip.show([Pair.new(tr(type), tr(type + "_desc"))])
	)
	type_txt.mouse_exited.connect(func():
		STooltip.close()
	)
	
	if thing is String:
		thing_txt.text = tr(thing)
	else:
		var item = thing as Item
		socket_sp.frame = item.image_id
		thing_txt.hide()
		socket_sp_ctrl.show()
	if thing is String:
		thing_txt.mouse_entered.connect(func():
			SSound.se_select.play()
			STooltip.show([Pair.new(tr(thing), tr(thing + "_desc"))])
		)
		thing_txt.mouse_exited.connect(func():
			STooltip.close()
		)
	else:
		socket_sp_ctrl.mouse_entered.connect(func():
			SSound.se_select.play()
			var item = thing as Item
			STooltip.show(item.get_tooltip())
		)
		socket_sp_ctrl.mouse_exited.connect(func():
			STooltip.close()
		)
	button.button.text = tr(type)
	button.button.disabled = true
	button.price.text = "%d" % price
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
			load_gem(payload)
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
			STooltip.show(gem.get_tooltip())
	)
	slot.mouse_exited.connect(func():
		STooltip.close()
	)
	button.button.pressed.connect(func():
		if !gem || Game.coins < price:
			Game.status_bar_ui.coins_text.hint()
			return
		if type == "w_enchant":
			var es = Buff.find_all_typed(gem, Buff.Type.Enchant)
			if es.size() >= 2:
				SSound.se_error.play()
				Game.banner_ui.show_tip(tr("ui_enchant_quantity_limit"), "", 1.0)
				return
		
		button.button.disabled = true
		Game.coins -= price
		SSound.se_coin.play()
		
		var tween = get_tree().create_tween()
		tween.tween_interval(0.2)
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
		elif type == "w_socket":
			socket_sp.reparent(self)
			tween.tween_property(socket_sp, "position", slot.get_rect().get_center() - Vector2(16.0, 16.0), 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART)
		tween.tween_callback(func():
			if type == "w_enchant":
				if thing == "w_enchant_charming":
					var bid = Buff.create(gem, Buff.Type.ValueModifier, {"target":"base_score","add":24}, Buff.Duration.Eternal)
					Buff.create(gem, Buff.Type.Enchant, {"type":"w_enchant_charming","bid":bid}, Buff.Duration.Eternal)
				elif thing == "w_enchant_sharp":
					var bid = Buff.create(gem, Buff.Type.ValueModifier, {"target":"mult","add":1.0}, Buff.Duration.Eternal)
					Buff.create(gem, Buff.Type.Enchant, {"type":"w_enchant_sharp","bid":bid}, Buff.Duration.Eternal)
				elif thing == "w_wild":
					var bid = Buff.create(gem, Buff.Type.ChangeColor, {"color":Gem.Type.Wild}, Buff.Duration.Eternal)
					Buff.create(gem, Buff.Type.Enchant, {"type":"w_wild","bid":bid}, Buff.Duration.Eternal)
				elif thing == "w_omni":
					var bid = Buff.create(gem, Buff.Type.ChangeRune, {"rune":Gem.Rune.Omni}, Buff.Duration.Eternal)
					Buff.create(gem, Buff.Type.Enchant, {"type":"w_omni","bid":bid}, Buff.Duration.Eternal)
			elif type == "w_socket":
				Game.add_item(thing)
				gem.rune = Gem.Rune.None
				gem.bound_item = thing
			elif type == "w_delete":
				Game.delete_gem(gem, gem_ui, "craft_slot")
				gem = null
			elif type == "w_duplicate":
				Game.duplicate_gem(gem, gem_ui, "craft_slot")
		)
		if type == "w_enchant":
			tween.tween_interval(0.3)
		elif type == "w_socket":
			tween.tween_callback(func():
				socket_sp.hide()
				gem_ui.set_image(gem.type, gem.rune, gem.bound_item.image_id)
				particles1.emitting = true
			)
			tween.tween_interval(0.7)
			tween.tween_callback(func():
				SSound.se_enchant.play()
				particles2.emitting = true
			)
			tween.tween_interval(0.7)
		elif type == "w_delete":
			tween.tween_interval(0.7)
		elif type == "w_duplicate":
			tween.tween_interval(1.3)
		tween.tween_callback(func():
			unload_gem()
		)
		tween.tween_property(self, "modulate:a", 0.0, 0.2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART)
		tween.tween_callback(func():
			Game.save_to_file()
			self.queue_free()
		)
	)

func _exit_tree() -> void:
	if gem:
		unload_gem()
	Drag.remove_target(slot)
