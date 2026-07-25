class_name BlockPalette
extends Control

## Bottom-of-screen block palette (PRD §6.1). The selection state here is
## authoritative — other systems (placement, FO-013) read `selected`.
## Built from BlockDefinition resources, not one hardcoded button per type.

signal block_selected(definition: BlockDefinition)
signal block_deselected()

@export var block_definitions: Array[BlockDefinition] = []
@export var bottom_margin: float = 24.0

var selected: BlockDefinition = null

@onready var _button_row: HBoxContainer = $Margin/Row
@onready var _cancel_button: Button = $CancelButton
var _type_buttons: Dictionary = {}


func _ready() -> void:
	_apply_safe_area_margin()
	for definition in block_definitions:
		_add_button_for(definition)
	_cancel_button.pressed.connect(_deselect)
	_cancel_button.visible = false


func _apply_safe_area_margin() -> void:
	# Simplified: a fixed margin rather than querying DisplayServer, which
	# returned a value large enough to crush the whole layout on-device
	# (root cause not chased further — flagged in BACKLOG for Phase 4 when
	# real UI work needs this properly).
	$Margin.add_theme_constant_override(&"margin_bottom", int(bottom_margin))


func _add_button_for(definition: BlockDefinition) -> void:
	var button: Button = Button.new()
	button.text = "%s\n%d coins" % [definition.display_name, definition.coin_price]
	button.custom_minimum_size = Vector2(140, 88)
	button.toggle_mode = true
	button.add_theme_color_override(&"font_color", Palette.WHITE)
	button.pressed.connect(_on_type_button_pressed.bind(definition, button))
	_button_row.add_child(button)
	_type_buttons[definition] = button


func _on_type_button_pressed(definition: BlockDefinition, button: Button) -> void:
	if selected == definition:
		_deselect()
		return
	if selected != null and _type_buttons.has(selected):
		_type_buttons[selected].button_pressed = false
	selected = definition
	button.button_pressed = true
	_cancel_button.visible = true
	block_selected.emit(definition)


func _deselect() -> void:
	if selected != null and _type_buttons.has(selected):
		_type_buttons[selected].button_pressed = false
	selected = null
	_cancel_button.visible = false
	block_deselected.emit()
