extends Control

const UiStatusBar = preload("res://ui_status_bar.gd")
const UiRelicsBar = preload("res://ui_relics_bar.gd")
const UiPatternsBar = preload("res://ui_patterns_bar.gd")

@onready var game_overlay : Control = $Overlay
@onready var status_bar : UiStatusBar = $VBoxContainer/MarginContainer/TopBar/VBoxContainer/MarginContainer/StatusBar
@onready var relics_bar : UiRelicsBar = $VBoxContainer/Control/MarginContainer/RelicsBar
@onready var patterns_bar : UiPatternsBar = $VBoxContainer/Control/MarginContainer2/PatternsBar
