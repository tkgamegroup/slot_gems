extends Panel

@onready var tab_comtainer : TabContainer = $PanelContainer/VBoxContainer/TabContainer
@onready var how_to_play_text : RichTextLabel = $PanelContainer/VBoxContainer/TabContainer/Tab1/Text
@onready var close_button : Button = $PanelContainer/VBoxContainer/Button

func _ready() -> void:
	tab_comtainer.set_tab_title(0, tr("ui_tutorial_how_to_play_title"))
	how_to_play_text.text = tr("ui_tutorial_how_to_play_text")
	close_button.pressed.connect(func():
		self.hide()
	)
