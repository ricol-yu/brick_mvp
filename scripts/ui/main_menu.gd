## 主入口场景脚本
## 游戏启动时的第一个场景，负责初始化和菜单导航
extends Control

@onready var title_label: Label = $VBoxContainer/TitleLabel
@onready var start_button: Button = $VBoxContainer/StartButton
@onready var shop_button: Button = $VBoxContainer/ShopButton
@onready var quit_button: Button = $VBoxContainer/QuitButton
@onready var coins_label: Label = $CoinsLabel

func _ready() -> void:
	# 确保 Control 节点继承全局字体主题（WebGL 下静态场景可能不自动继承）
	var root_theme := get_tree().root.theme
	if root_theme and root_theme.default_font:
		theme = root_theme
	
	GameManager.change_state(GameManager.GameState.MAIN_MENU)
	start_button.pressed.connect(_on_start_pressed)
	shop_button.pressed.connect(_on_shop_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	EventBus.coins_changed.connect(_on_coins_changed)
	_update_coins_display()
	AudioManager.play_menu_bgm()

func _on_start_pressed() -> void:
	AudioManager.play_sfx("button_click")
	SceneManager.goto_game_world()

func _on_shop_pressed() -> void:
	AudioManager.play_sfx("button_click")
	SceneManager.goto_meta_shop()

func _on_quit_pressed() -> void:
	AudioManager.play_sfx("button_click")
	get_tree().quit()

func _on_coins_changed(_amount: int) -> void:
	_update_coins_display()

func _update_coins_display() -> void:
	coins_label.text = "金币: %d" % SaveManager.get_coins()
