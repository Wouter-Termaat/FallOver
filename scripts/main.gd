extends Node3D

## FO-001 placeholder main scene.
##
## Exists only to prove the project is configured and runs. It will be replaced
## as soon as there is real content to show. Colours come from Palette so that
## even this throwaway screen obeys PRD §8.4 — never hardcode a colour.

@export var title_text: String = "Fall Over"
@export var subtitle_text: String = "project skeleton — FO-001"
@export var title_font_size: int = 96
@export var subtitle_font_size: int = 36

@onready var _background: ColorRect = $UI/Background
@onready var _title: Label = $UI/Text/Title
@onready var _subtitle: Label = $UI/Text/Subtitle


func _ready() -> void:
	_background.color = Palette.LIGHT_BLUE

	_title.text = title_text
	_title.add_theme_color_override(&"font_color", Palette.WHITE)
	_title.add_theme_font_size_override(&"font_size", title_font_size)

	_subtitle.text = subtitle_text
	_subtitle.add_theme_color_override(&"font_color", Palette.WHITE)
	_subtitle.add_theme_font_size_override(&"font_size", subtitle_font_size)

	print("Fall Over — project skeleton running. Godot %s" % Engine.get_version_info().string)
