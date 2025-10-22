extends Panel

@onready var panel : Control = $PanelContainer
@onready var text : RichTextLabel = $PanelContainer/VBoxContainer/Text
@onready var prev_button : Button = $PanelContainer/VBoxContainer/HBoxContainer/Prev
@onready var next_button : Button = $PanelContainer/VBoxContainer/HBoxContainer/Next
@onready var elements_image : TextureRect = $Elements
@onready var close_button : Button = $PanelContainer/VBoxContainer/HBoxContainer/Button

var view_idx : int = 0

func update_view():
	match view_idx:
		0: 
			text.text = tr("ui_tutorial_how_to_play_text")
			elements_image.show()
		1: 
			text.text = tr("ui_tutorial_gem_text")
			elements_image.hide()
	prev_button.disabled = view_idx == 0
	next_button.disabled = view_idx == 1

func enter():
	STooltip.close()
	
	view_idx = 0
	update_view()
	
	self.show()
	self.modulate.a = 0.0
	var tween = get_tree().create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.3)
	
func exit():
	self.modulate.a = 1.0
	var tween = get_tree().create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.3)
	tween.tween_callback(func():
		self.hide()
	)

func _ready() -> void:
	text.meta_hover_started.connect(func(meta):
		var s = str(meta)
		if s.begins_with("w_"):
			STooltip.show(text, 1, [Pair.new(tr(s), tr(s + "_desc"))])
		elif s.begins_with("gem_"):
			STooltip.show(text, 1, [Pair.new(tr(s), "")])
		elif s.begins_with("rune_"):
			STooltip.show(text, 1, [Pair.new(tr(s), "")])
		elif s.begins_with("relic_"):
			var r = Relic.new()
			r.setup(s.substr(6))
			STooltip.show(text, 1, r.get_tooltip())
	)
	text.meta_hover_ended.connect(func(meta):
		STooltip.close()
	)
	
	prev_button.pressed.connect(func():
		if view_idx > 0:
			view_idx -= 1
			update_view()
	)
	next_button.pressed.connect(func():
		if view_idx < 1:
			view_idx += 1
			update_view()
	)
	
	close_button.pressed.connect(func():
		exit()
	)
