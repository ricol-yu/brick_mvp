## 游戏全局状态管理（Autoload）
## 管理游戏状态机：主菜单 → 游戏中 → 暂停 → 结算
extends Node

## 游戏状态枚举
enum GameState {
	MAIN_MENU,     ## 主菜单
	PREPARING,     ## 准备阶段（球在挡板上等待发射）
	PLAYING,       ## 游戏进行中
	PAUSED,        ## 暂停
	BUILD_SELECT,  ## Build 选择界面
	GAME_OVER,     ## 游戏结束
	META_SHOP,     ## 永久升级商店
}

## 当前游戏状态
var current_state: GameState = GameState.MAIN_MENU

## 单局统计数据
var run_stats: Dictionary = {
	"bricks_destroyed": 0,
	"total_damage_dealt": 0.0,
	"perfect_bounces": 0,
	"builds_selected": 0,
	"bosses_defeated": 0,
	"bonus_bricks_hit": 0,
	"bonus_bricks_missed": 0,
	"run_duration": 0.0,
	"max_level_reached": 1,
}

## 单局计时器
var run_timer: float = 0.0

## 球是否已发射（用于判断 Build 选择后应返回 PREPARING 还是 PLAYING）
var ball_launched: bool = false

func _ready() -> void:
	EventBus.game_started.connect(_on_game_started)
	EventBus.brick_destroyed.connect(_on_brick_destroyed)
	EventBus.boss_defeated.connect(_on_boss_defeated)
	EventBus.bonus_brick_destroyed.connect(_on_bonus_brick_destroyed)

func _process(delta: float) -> void:
	if current_state == GameState.PLAYING:
		run_timer += delta
		run_stats["run_duration"] = run_timer

## 切换游戏状态
func change_state(new_state: GameState) -> void:
	var old_state := current_state
	current_state = new_state
	
	match new_state:
		GameState.PAUSED:
			get_tree().paused = true
			EventBus.game_paused.emit(true)
		GameState.BUILD_SELECT:
			get_tree().paused = true
		GameState.PREPARING:
			if old_state == GameState.BUILD_SELECT:
				get_tree().paused = false
		GameState.PLAYING:
			if old_state == GameState.PAUSED or old_state == GameState.BUILD_SELECT:
				get_tree().paused = false
				if old_state == GameState.PAUSED:
					EventBus.game_paused.emit(false)

## 开始新一局
func start_new_run() -> void:
	_reset_run_stats()
	run_timer = 0.0
	ball_launched = false
	change_state(GameState.PREPARING)

## 发射球（从准备阶段进入游戏中）
func launch_ball() -> void:
	if current_state == GameState.PREPARING:
		ball_launched = true
		change_state(GameState.PLAYING)
		EventBus.ball_launched.emit()

## 游戏结束
func end_game(cleared: bool) -> void:
	change_state(GameState.GAME_OVER)
	EventBus.game_over.emit(cleared, run_stats.duplicate())
	SceneManager.goto_game_over(cleared, run_stats.duplicate())

## 暂停/恢复
func toggle_pause() -> void:
	if current_state == GameState.PLAYING:
		change_state(GameState.PAUSED)
	elif current_state == GameState.PAUSED:
		change_state(GameState.PLAYING)

func _on_game_started() -> void:
	start_new_run()

func _on_brick_destroyed(_brick: Node, _exp: int) -> void:
	run_stats["bricks_destroyed"] += 1

func _on_boss_defeated(_boss: Node) -> void:
	run_stats["bosses_defeated"] += 1

func _on_bonus_brick_destroyed(_build: Resource) -> void:
	run_stats["bonus_bricks_hit"] += 1

func _reset_run_stats() -> void:
	run_stats = {
		"bricks_destroyed": 0,
		"total_damage_dealt": 0.0,
		"perfect_bounces": 0,
		"builds_selected": 0,
		"bosses_defeated": 0,
		"bonus_bricks_hit": 0,
		"bonus_bricks_missed": 0,
		"run_duration": 0.0,
		"max_level_reached": 1,
	}
