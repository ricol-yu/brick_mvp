## EXP 累积与升级系统（Autoload）
## 管理经验值获取、等级提升、触发 Build 选择
extends Node

## 当前经验值
var current_exp: int = 0

## 当前等级
var current_level: int = 1

## 当前等级已获得的经验（用于计算下一级进度）
var exp_in_current_level: int = 0

func _ready() -> void:
	EventBus.brick_destroyed.connect(_on_brick_destroyed)
	EventBus.bonus_brick_destroyed.connect(_on_bonus_brick_destroyed)
	EventBus.game_started.connect(_on_game_started)

## 获取当前等级升级所需经验
func get_exp_needed() -> int:
	return BalanceData.get_exp_for_level(current_level)

## 获取当前等级进度（0.0 ~ 1.0）
func get_exp_progress() -> float:
	var needed := get_exp_needed()
	if needed <= 0:
		return 0.0
	return clampf(float(exp_in_current_level) / float(needed), 0.0, 1.0)

## 增加经验值
func add_exp(amount: int) -> void:
	current_exp += amount
	exp_in_current_level += amount
	EventBus.exp_gained.emit(amount)
	
	# 检查是否升级
	_check_level_up()

## 检查并处理升级
func _check_level_up() -> void:
	if current_level >= BalanceData.MAX_LEVEL:
		return
	
	var needed := get_exp_needed()
	while exp_in_current_level >= needed and current_level < BalanceData.MAX_LEVEL:
		exp_in_current_level -= needed
		current_level += 1
		GameManager.run_stats["max_level_reached"] = maxi(
			GameManager.run_stats["max_level_reached"], current_level
		)
		EventBus.level_up.emit(current_level)
		_request_build_selection()
		
		needed = get_exp_needed()
		if needed <= 0:
			break

## 请求 Build 选择（升级时触发）
func _request_build_selection() -> void:
	GameManager.change_state(GameManager.GameState.BUILD_SELECT)
	var builds := BuildSystem.generate_build_options(3)
	EventBus.show_build_selection.emit(builds)

## 重置（新一局开始时）
func reset() -> void:
	current_exp = 0
	current_level = 1
	exp_in_current_level = 0

func _on_game_started() -> void:
	reset()

func _on_brick_destroyed(_brick: Node, exp_reward: int) -> void:
	add_exp(exp_reward)

func _on_bonus_brick_destroyed(_build: Resource) -> void:
	# Bonus Brick 不直接给 EXP，而是给 Build 选项
	pass
