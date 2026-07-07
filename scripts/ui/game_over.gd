## 游戏结束画面脚本
## 显示本局结算数据，提供返回主菜单/重玩选项
extends Control

@onready var title_label: Label = $PanelContainer/VBoxContainer/TitleLabel
@onready var stats_label: Label = $PanelContainer/VBoxContainer/StatsLabel
@onready var coins_label: Label = $PanelContainer/VBoxContainer/CoinsLabel
@onready var retry_button: Button = $PanelContainer/VBoxContainer/ButtonRow/RetryButton
@onready var menu_button: Button = $PanelContainer/VBoxContainer/ButtonRow/MenuButton

## 结算数据
var run_stats: Dictionary = {}
var cleared: bool = false
var coins_earned: int = 0

func _ready() -> void:
	retry_button.pressed.connect(_on_retry_pressed)
	menu_button.pressed.connect(_on_menu_pressed)
	EventBus.game_over.connect(_on_game_over)
	# 如果连接时已经有数据（通过 SceneManager 传入），直接显示
	if not run_stats.is_empty():
		_display_results()

## 接收游戏结束数据
func _on_game_over(is_cleared: bool, stats: Dictionary) -> void:
	cleared = is_cleared
	run_stats = stats
	_calculate_coins()
	_display_results()

## 计算金币奖励
func _calculate_coins() -> void:
	var base_coins: int = run_stats.get("bricks_destroyed", 0) * 1
	var boss_bonus: int = run_stats.get("bosses_defeated", 0) * 10
	coins_earned = base_coins + boss_bonus
	# 应用永久升级加成
	coins_earned = int(coins_earned * MetaProgression.get_coin_bonus_multiplier())
	if coins_earned > 0:
		SaveManager.add_coins(coins_earned)
		EventBus.run_settled.emit(coins_earned)

## 显示结算结果
func _display_results() -> void:
	if cleared:
		title_label.text = "通关成功！"
		title_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2))
	else:
		title_label.text = "游戏结束"
		title_label.add_theme_color_override("font_color", Color(1.0, 0.3, 0.3))
	
	var duration: float = run_stats.get("run_duration", 0.0)
	var minutes := int(duration) / 60
	var seconds := int(duration) % 60
	
	stats_label.text = "击碎砖块: %d\n最高等级: Lv.%d\n存活时间: %02d:%02d\nBoss 击败: %d\n完美反弹: %d" % [
		run_stats.get("bricks_destroyed", 0),
		run_stats.get("max_level_reached", 1),
		minutes, seconds,
		run_stats.get("bosses_defeated", 0),
		run_stats.get("perfect_bounces", 0),
	]
	
	coins_label.text = "获得金币: %d" % coins_earned

func _on_retry_pressed() -> void:
	SceneManager.goto_game_world()

func _on_menu_pressed() -> void:
	SceneManager.goto_main_menu()
