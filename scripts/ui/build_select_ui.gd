## Build 三选一 UI 脚本
## 显示 3 个 Build 选项卡片，玩家点击后选择
extends CanvasLayer

@onready var panel: PanelContainer = $PanelContainer
@onready var title_label: Label = $PanelContainer/VBoxContainer/TitleLabel
@onready var cards_container: HBoxContainer = $PanelContainer/VBoxContainer/CardsContainer
## Build 卡片使用纯代码构建（无需场景文件）

func _ready() -> void:
	EventBus.show_build_selection.connect(_on_show_build_selection)
	panel.visible = false
	# 游戏树暂停时（BUILD_SELECT 状态），UI 仍需响应输入
	process_mode = Node.PROCESS_MODE_ALWAYS
	# 给面板添加可见背景（深色半透明遮罩 + 面板底色）
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0.1, 0.1, 0.15, 0.95)
	panel_style.set_border_width_all(2)
	panel_style.border_color = Color(0.4, 0.4, 0.5)
	panel_style.set_corner_radius_all(12)
	panel_style.set_content_margin_all(20)
	panel.add_theme_stylebox_override("panel", panel_style)

## 显示 Build 选择界面
func _on_show_build_selection(builds: Array) -> void:
	panel.visible = true
	_clear_cards()
	
	for build in builds:
		if build is BuildData:
			_create_card(build)

## 创建一张 Build 卡片
func _create_card(build_data: BuildData) -> void:
	var card := _create_card_ui(build_data)
	cards_container.add_child(card)

## 创建卡片 UI（纯代码构建，无需场景文件）
func _create_card_ui(build_data: BuildData) -> Control:
	var card := PanelContainer.new()
	card.custom_minimum_size = Vector2(200, 280)
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	# 稀有度边框颜色
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.15, 0.15, 0.2)
	style.border_color = build_data.get_rarity_color()
	style.set_border_width_all(3)
	style.set_corner_radius_all(8)
	style.set_content_margin_all(12)
	card.add_theme_stylebox_override("panel", style)
	
	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 8)
	card.add_child(vbox)
	
	# Build 名称
	var name_label := Label.new()
	name_label.text = build_data.name
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.add_theme_color_override("font_color", build_data.get_rarity_color())
	vbox.add_child(name_label)
	
	# 稀有度标签
	var rarity_label := Label.new()
	rarity_label.text = "[%s]" % build_data.rarity
	rarity_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	rarity_label.add_theme_color_override("font_color", build_data.get_rarity_color())
	rarity_label.add_theme_font_size_override("font_size", 12)
	vbox.add_child(rarity_label)
	
	# 描述
	var desc_label := Label.new()
	desc_label.text = build_data.description
	desc_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc_label.add_theme_font_size_override("font_size", 14)
	vbox.add_child(desc_label)
	
	# 等级信息
	var level_label := Label.new()
	level_label.text = "等级: %d/%d" % [build_data.current_level + 1, build_data.max_level]
	level_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	level_label.add_theme_font_size_override("font_size", 12)
	vbox.add_child(level_label)
	
	# Tags
	var tags_label := Label.new()
	tags_label.text = "标签: " + ", ".join(build_data.tags)
	tags_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tags_label.add_theme_font_size_override("font_size", 10)
	tags_label.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
	vbox.add_child(tags_label)
	
	# 底部弹簧：将按钮推到底部
	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(spacer)
	
	# 选择按钮
	var select_button := Button.new()
	select_button.text = "选择"
	select_button.custom_minimum_size = Vector2(150, 40)
	select_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	select_button.pressed.connect(func(): _on_card_selected(build_data))
	vbox.add_child(select_button)
	
	return card

## 玩家选择了某个 Build
func _on_card_selected(build_data: BuildData) -> void:
	EventBus.build_selected.emit(build_data)
	panel.visible = false

## 清除所有卡片
func _clear_cards() -> void:
	for child in cards_container.get_children():
		child.queue_free()
