## Build 系统（Autoload）
## 管理 Build 的选择、应用、效果叠加，是整个 Roguelike 构筑系统的核心
extends Node

## Build 池
var build_pool: BuildPool = BuildPool.new()

## Tag 系统
var tag_system: TagSystem = TagSystem.new()

## 当前局已选择的 Build 列表
var selected_builds: Array[BuildData] = []

## 待显示的 Build 选项（GameWorld 就绪后取走）
var pending_build_options: Array = []

func _ready() -> void:
	EventBus.game_started.connect(_on_game_started)
	EventBus.build_selected.connect(_on_build_selected)

## 生成 Build 选项（升级时调用）
func generate_build_options(count: int) -> Array[BuildData]:
	return build_pool.select_builds(count, tag_system, ExpSystem.current_level)

## 玩家选择了 Build（UI 回调）
func apply_build(build_data: BuildData) -> void:
	build_data.level_up()
	selected_builds.append(build_data)
	tag_system.add_build_tags(build_data)
	
	# 通知各实体应用 Build 效果
	EventBus.build_applied.emit(build_data)
	
	GameManager.run_stats["builds_selected"] += 1
	# 如果球已发射过，返回 PLAYING；否则返回 PREPARING（等待玩家发射球）
	if GameManager.ball_launched:
		GameManager.change_state(GameManager.GameState.PLAYING)
	else:
		GameManager.change_state(GameManager.GameState.PREPARING)

## 获取当前已选择的所有 Build
func get_selected_builds() -> Array[BuildData]:
	return selected_builds

## 获取特定类型的 Build 列表
func get_builds_by_type(type: String) -> Array[BuildData]:
	return selected_builds.filter(func(b): return b.type == type)

## 重置（新一局开始时）
func reset() -> void:
	selected_builds.clear()
	tag_system.reset()
	build_pool.reset_all_build_levels()
	# 注意：不在 reset 中清空 pending_build_options，由 consume_pending_options 消费

## 确保 build pool 已加载（幂等操作）
func ensure_builds_loaded() -> void:
	if build_pool.all_builds.is_empty():
		build_pool.load_builds()

## 生成并存储 Build 选项（供 GameWorld 取走显示）
func generate_and_store_build_options(count: int) -> void:
	ensure_builds_loaded()
	pending_build_options = generate_build_options(count)

## 消费待选 Build 选项（取出并清空）
func consume_pending_options() -> Array:
	var options := pending_build_options
	pending_build_options = []
	return options

func _on_game_started() -> void:
	reset()
	ensure_builds_loaded()

func _on_build_selected(build_data: Resource) -> void:
	if build_data is BuildData:
		apply_build(build_data)
