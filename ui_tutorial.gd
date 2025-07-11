extends Panel

@onready var how_to_play_text : RichTextLabel = $PanelContainer/VBoxContainer/Text
@onready var close_button : Button = $PanelContainer/VBoxContainer/Button

func enter():
	how_to_play_text.text = tr("ui_tutorial_how_to_play_text")
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
	close_button.pressed.connect(func():
		exit()
	)
