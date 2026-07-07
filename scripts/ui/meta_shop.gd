## 永久升级商店脚本
## 显示可用升级项，使用金币购买
extends Control

@onready var title_label: Label = $PanelContainer/VBoxContainer/TitleLabel
@onready var coins_label: Label = $PanelContainer/VBoxContainer/CoinsLabel
@onready var upgrades_container: VBoxContainer = $PanelContainer/VBoxContainer/ScrollContainer/UpgradesContainer
@onready var back_button: Button = $PanelContainer/VBoxContainer/BackButton

func _ready() -> void:
	GameManager.change_state(GameManager.GameState.META_SHOP)
	back_button.pressed.connect(_on_back_pressed)
	EventBus.coins_changed.connect(_on_coins_changed)
	_refresh_ui()

## 刷新 UI
func _refresh_ui() -> void:
	_update_coins_display()
	_clear_upgrade_cards()
	
	for upgrade_id in MetaProgression.UPGRADES:
		var info: Dictionary = MetaProgression.UPGRADES[upgrade_id]
		_create_upgrade_card(upgrade_id, info)

## 创建升级卡片
func _create_upgrade_card(upgrade_id: String, info: Dictionary) -> void:
	var card := HBoxContainer.new()
	card.add_theme_constant_override("separation", 10)
	
	var level := MetaProgression.get_upgrade_level(upgrade_id)
	var max_level: int = info["max_level"]
	var cost := MetaProgression.get_upgrade_cost(upgrade_id)
	var is_maxed := level >= max_level
	
	# 名称和描述
	var info_vbox := VBoxContainer.new()
	info_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	var name_label := Label.new()
	name_label.text = "%s [%d/%d]" % [info["name"], level, max_level]
	info_vbox.add_child(name_label)
	
	var desc_label := Label.new()
	desc_label.text = str(info["description"])
	desc_label.add_theme_font_size_override("font_size", 12)
	desc_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	info_vbox.add_child(desc_label)
	
	card.add_child(info_vbox)
	
	# 购买按钮
	var buy_button := Button.new()
	buy_button.custom_minimum_size = Vector2(120, 40)
	if is_maxed:
		buy_button.text = "已满级"
		buy_button.disabled = true
	else:
		buy_button.text = "购买 (%d 金币)" % cost
		var can_afford := SaveManager.get_coins() >= cost
		buy_button.disabled = not can_afford
		buy_button.pressed.connect(func(): _on_buy_pressed(upgrade_id))
	
	card.add_child(buy_button)
	
	upgrades_container.add_child(card)

## 购买升级
func _on_buy_pressed(upgrade_id: String) -> void:
	if MetaProgression.try_purchase(upgrade_id):
		_refresh_ui()

## 返回主菜单
func _on_back_pressed() -> void:
	SceneManager.goto_main_menu()

## 更新金币显示
func _update_coins_display() -> void:
	coins_label.text = "金币: %d" % SaveManager.get_coins()

func _on_coins_changed(_amount: int) -> void:
	_update_coins_display()

## 清除升级卡片
func _clear_upgrade_cards() -> void:
	for child in upgrades_container.get_children():
		child.queue_free()
