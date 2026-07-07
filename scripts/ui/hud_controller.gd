## HUD 控制器脚本
## 显示游戏内信息：等级、EXP 进度条、分数、时间
extends CanvasLayer

@onready var stage_label: Label = $MarginContainer/VBoxContainer/TopBar/StageLabel
@onready var level_label: Label = $MarginContainer/VBoxContainer/TopBar/LevelLabel
@onready var exp_bar: ProgressBar = $MarginContainer/VBoxContainer/TopBar/ExpBar
@onready var score_label: Label = $MarginContainer/VBoxContainer/TopBar/ScoreLabel
@onready var time_label: Label = $MarginContainer/VBoxContainer/TopBar/TimeLabel
@onready var ball_count_label: Label = $MarginContainer/VBoxContainer/TopBar/BallCountLabel

func _ready() -> void:
	EventBus.exp_gained.connect(_on_exp_gained)
	EventBus.level_up.connect(_on_level_up)
	EventBus.brick_destroyed.connect(_on_brick_destroyed)
	EventBus.ball_launched.connect(_on_ball_launched)
	EventBus.stage_changed.connect(_on_stage_changed)

func _process(_delta: float) -> void:
	_update_time_display()
	_update_exp_bar()

## 更新 EXP 进度条
func _update_exp_bar() -> void:
	exp_bar.value = ExpSystem.get_exp_progress() * 100.0

## 更新时间显示
func _update_time_display() -> void:
	var total_seconds := int(GameManager.run_timer)
	var minutes := total_seconds / 60
	var seconds := total_seconds % 60
	time_label.text = "%02d:%02d" % [minutes, seconds]

## 更新等级显示
func _update_level_display(level: int) -> void:
	level_label.text = "Lv.%d" % level

## 更新分数
var total_bricks_destroyed: int = 0
func _update_score_display() -> void:
	score_label.text = "砖块: %d" % total_bricks_destroyed

func _on_exp_gained(_amount: int) -> void:
	pass  # EXP bar 每帧自动更新

func _on_level_up(new_level: int) -> void:
	_update_level_display(new_level)

func _on_brick_destroyed(_brick: Node, _exp: int) -> void:
	total_bricks_destroyed += 1
	_update_score_display()

func _on_ball_launched() -> void:
	ball_count_label.text = "球: 1"

func _on_stage_changed(stage_index: int, stage_name: String) -> void:
	stage_label.text = "%d. %s" % [stage_index, stage_name]
