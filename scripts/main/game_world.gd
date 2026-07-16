## 游戏世界场景脚本
## 管理墙壁、砖块容器、底线、砖块生成器、关卡推进、砖块下压、Boss 生成
extends Node2D

## 场景预加载
const BALL_SCENE := preload("res://scenes/entities/ball/ball.tscn")
const PADDLE_SCENE := preload("res://scenes/entities/paddle/paddle.tscn")
const HUD_SCENE := preload("res://scenes/ui/hud.tscn")
const BUILD_SELECT_SCENE := preload("res://scenes/ui/build_select.tscn")
const BOSS_SCENE := preload("res://scenes/entities/boss/boss.tscn")
const BONUS_BRICK_SCENE := preload("res://scenes/entities/bricks/bonus_brick.tscn")

## 砖块场景映射
const BRICK_SCENES: Dictionary = {
	"normal": "res://scenes/entities/bricks/brick_normal.tscn",
	"hard": "res://scenes/entities/bricks/brick_hard.tscn",
	"split": "res://scenes/entities/bricks/brick_split.tscn",
	"regen": "res://scenes/entities/bricks/brick_regen.tscn",
	"ghost": "res://scenes/entities/bricks/brick_ghost.tscn",
	"shield": "res://scenes/entities/bricks/brick_shield.tscn",
	"haste": "res://scenes/entities/bricks/brick_haste.tscn",
	"curse": "res://scenes/entities/bricks/brick_curse.tscn",
}

## 子节点引用
@onready var ball_container: Node2D = $BallContainer
@onready var brick_container: Node2D = $BrickContainer
@onready var paddle: CharacterBody2D = $Paddle
@onready var ball: CharacterBody2D = $Ball
@onready var bottom_line: StaticBody2D = $BottomLine

## HUD 和 BuildSelectUI（运行时实例化）
var hud: CanvasLayer = null
var build_select_ui: CanvasLayer = null

## 关卡管理
var current_level_index: int = 0
var level_data_list: Array[Resource] = []
var current_level_data: Resource = null

## 当前关卡行生成进度（波次系统）
var current_row_index: int = 0

## 砖块下压系统
var push_speed: float = BalanceData.BRICK_PUSH_SPEED_INITIAL
var push_timer: float = 0.0
var row_spawn_timer: float = 0.0
var row_spawn_interval: float = BalanceData.BRICK_ROW_SPAWN_INTERVAL
var push_speed_increment_timer: float = 0.0

## 当前球数量
var ball_count: int = 1

## 当前 Boss 引用
var current_boss: CharacterBody2D = null

## Bonus Brick 生成计时器
var bonus_brick_timer: float = 0.0
var bonus_brick_interval: float = 0.0

## Safety Build 减速效果
var push_speed_slow_timer: float = 0.0
var push_speed_slow_duration: float = 5.0  ## 减速持续 5 秒
var push_speed_reduction: float = 0.0

## 加速砖 Boost 效果
var push_speed_boost_multiplier: float = 1.0
var push_speed_boost_timer: float = 0.0

## 底线 Y 坐标
const BOTTOM_LINE_Y_POS: float = 650.0

func _ready() -> void:
	add_to_group("game_world")
	EventBus.ball_hit_bottom.connect(_on_ball_hit_bottom)
	EventBus.brick_destroyed.connect(_on_brick_destroyed)
	EventBus.boss_defeated.connect(_on_boss_defeated)
	EventBus.game_started.connect(_on_game_started)
	EventBus.meta_start_balls_changed.connect(_on_meta_start_balls_changed)
	
	# 确保挡板在屏幕底部
	paddle.position = Vector2(BalanceData.WORLD_WIDTH * 0.5, BOTTOM_LINE_Y_POS - 30.0)
	
	# 确保球在挡板上方
	ball.position = Vector2(paddle.position.x, paddle.position.y - 30.0)
	
	# 实例化 HUD
	hud = HUD_SCENE.instantiate()
	add_child(hud)
	
	# 实例化 BuildSelectUI
	build_select_ui = BUILD_SELECT_SCENE.instantiate()
	add_child(build_select_ui)
	
	# 初始化 Bonus Brick 计时器
	_reset_bonus_brick_timer()
	
	# 加载关卡数据
	_load_level_data()
	
	# 生成初始砖块
	_spawn_level_bricks()
	
	# 检查是否需要生成 Boss
	_try_spawn_boss()
	
	# 通知 HUD 当前关卡
	_notify_stage_changed()
	
	# 播放游戏 BGM
	AudioManager.play_game_bgm()
	
	# 检查是否有因初始 EXP 导致的待选 Build（MetaProgression 升级触发）
	_check_pending_build_selection()

func _process(delta: float) -> void:
	# 暂停切换
	if Input.is_action_just_pressed("pause"):
		GameManager.toggle_pause()
	
	if GameManager.current_state != GameManager.GameState.PLAYING:
		return
	
	# 砖块下压
	_update_brick_push(delta)
	
	# 新行生成计时
	_update_row_spawn(delta)
	
	# 下压速度递增（每 30 秒）
	_update_push_speed_increment(delta)
	
	# Bonus Brick 生成
	_update_bonus_brick_spawn(delta)
	
	# Safety Build 减速效果计时
	if push_speed_slow_timer > 0:
		push_speed_slow_timer -= delta
		if push_speed_slow_timer <= 0:
			push_speed_reduction = 0.0

## 关卡数据显式路径列表（避免 DirAccess 在 Web 导出时的兼容性问题）
const LEVEL_PATHS: Array[String] = [
	"res://data/levels/level_01.tres",
	"res://data/levels/level_02.tres",
	"res://data/levels/level_03.tres",
	"res://data/levels/level_04.tres",
	"res://data/levels/level_05.tres",
]

## 加载所有关卡数据文件
func _load_level_data() -> void:
	level_data_list.clear()
	for path in LEVEL_PATHS:
		if ResourceLoader.exists(path):
			var level_res := load(path)
			if level_res:
				level_data_list.append(level_res)
		else:
			push_warning("[GameWorld] 关卡文件不存在: " + path)
	
	if level_data_list.is_empty():
		_create_default_level()
	
	# 设置第一关
	current_level_index = 0
	if current_level_index < level_data_list.size():
		current_level_data = level_data_list[current_level_index]

## 创建默认关卡（兜底）
func _create_default_level() -> void:
	var default_level := LevelData.new()
	default_level.id = 1
	default_level.level_name = "默认关卡"
	default_level.rows = [
		{"type": "normal", "count": 15},
		{"type": "normal", "count": 15},
		{"type": "normal", "count": 15},
	]
	level_data_list.append(default_level)
	current_level_data = default_level

## 根据关卡数据初始化关卡（重置行生成进度，立即生成第一行）
func _spawn_level_bricks() -> void:
	if current_level_data == null:
		return
	
	# 重置行生成进度
	current_row_index = 0
	
	# 应用关卡下压倍率
	if current_level_data is LevelData:
		var ld := current_level_data as LevelData
		push_speed = BalanceData.BRICK_PUSH_SPEED_INITIAL * ld.push_speed_multiplier
	else:
		push_speed = BalanceData.BRICK_PUSH_SPEED_INITIAL
	
	# 根据关卡配置调整行间隔（row_spawn_multiplier 越大间隔越长）
	var spawn_mult := 1.0
	if current_level_data is LevelData:
		spawn_mult = (current_level_data as LevelData).row_spawn_multiplier
	row_spawn_interval = BalanceData.BRICK_ROW_SPAWN_INTERVAL * spawn_mult
	
	# 重置计时器
	push_timer = 0.0
	row_spawn_timer = 0.0
	push_speed_increment_timer = 0.0
	
	# 立即生成第一行
	_spawn_new_row()

## 尝试生成 Boss
func _try_spawn_boss() -> void:
	if current_level_data == null or not (current_level_data is LevelData):
		return
	var ld := current_level_data as LevelData
	if not ld.has_boss or ld.boss_id == "":
		return
	
	# 加载 Boss 数据
	var boss_data_path := "res://data/bosses/%s.tres" % ld.boss_id
	if not ResourceLoader.exists(boss_data_path):
		push_warning("Boss 数据不存在: " + boss_data_path)
		return
	
	var boss_data := load(boss_data_path) as BossData
	if boss_data == null:
		return
	
	# 生成 Boss
	var boss: CharacterBody2D = BOSS_SCENE.instantiate()
	boss.boss_data = boss_data
	boss.global_position = Vector2(BalanceData.WORLD_WIDTH * 0.5, 180.0)
	add_child(boss)
	current_boss = boss
	EventBus.boss_spawned.emit(boss)

## 应用 Safety Build 减速效果
func _apply_safety_build_slow() -> void:
	if ball and is_instance_valid(ball):
		var ball_script = ball as CharacterBody2D
		if ball_script.has_method("get") or ball_script.get("damage_calc"):
			var dc = ball_script.get("damage_calc")
			if dc and dc.get("push_speed_reduction") and dc.push_speed_reduction > 0:
				push_speed_reduction = dc.push_speed_reduction
				push_speed_slow_timer = push_speed_slow_duration

## 应用加速砖 Boost 效果（可叠加，取最大倍率）
func apply_push_speed_boost(multiplier: float, duration: float) -> void:
	if multiplier > push_speed_boost_multiplier:
		push_speed_boost_multiplier = multiplier
	push_speed_boost_timer = duration

## 砖块下压更新
func _update_brick_push(delta: float) -> void:
	# 加速 Boost 计时
	if push_speed_boost_timer > 0:
		push_speed_boost_timer -= delta
		if push_speed_boost_timer <= 0:
			push_speed_boost_multiplier = 1.0
	
	var effective_speed := push_speed * (1.0 - push_speed_reduction) * push_speed_boost_multiplier
	for brick in brick_container.get_children():
		if brick is Node2D:
			brick.position.y += effective_speed * delta
	
	# 检查是否有砖块到达底线
	for brick in brick_container.get_children():
		if brick is Node2D and brick.position.y >= BOTTOM_LINE_Y_POS:
			GameManager.end_game(false)
			return

## 新行生成计时
func _update_row_spawn(delta: float) -> void:
	row_spawn_timer += delta
	if row_spawn_timer >= row_spawn_interval:
		row_spawn_timer = 0.0
		_spawn_new_row()

## 在顶部生成新的一行砖块（按关卡配置的 rows 逐行生成）
func _spawn_new_row() -> void:
	var rows: Array = []
	if current_level_data is LevelData:
		rows = (current_level_data as LevelData).rows
	
	# 当前关卡的行已全部生成完毕，自动切换到下一关
	if current_row_index >= rows.size():
		# 测试关循环：不推进，重新从第一行开始
		if current_level_data is LevelData and (current_level_data as LevelData).id == 99:
			current_row_index = 0
			return
		current_level_index += 1
		if current_level_index >= level_data_list.size():
			GameManager.end_game(true)
			return
		current_level_data = level_data_list[current_level_index]
		current_row_index = 0
		rows = (current_level_data as LevelData).rows
		# 更新下压速度
		var ld := current_level_data as LevelData
		push_speed = BalanceData.BRICK_PUSH_SPEED_INITIAL * ld.push_speed_multiplier
		# 通知 HUD 关卡变化
		_notify_stage_changed()
		# 尝试生成 Boss
		_try_spawn_boss()
	
	var row_config: Dictionary = rows[current_row_index]
	var brick_w := 64.0
	var start_y := 40.0
	
	# 检查是否使用新的混合格式（"types" 数组）
	if row_config.has("types"):
		_spawn_mixed_row(row_config["types"], brick_w, start_y, row_config)
	else:
		# 旧格式：单类型行
		var brick_type: String = row_config.get("type", "normal")
		var col_count: int = row_config.get("count", 15)
		var slots: int = row_config.get("slots", col_count)  # slots 为空位总数
		var scene_path: String = BRICK_SCENES.get(brick_type, BRICK_SCENES["normal"])
		var brick_scene := load(scene_path)
		
		if slots > col_count:
			# 有空隙：生成槽位布局，随机分配砖块和空隙
			var layout := _generate_layout(slots, col_count)
			var start_x := (BalanceData.WORLD_WIDTH - slots * brick_w) * 0.5 + brick_w * 0.5
			for idx in range(slots):
				if layout[idx]:  # true = 放砖块
					var brick: Node2D = brick_scene.instantiate()
					brick.position = Vector2(start_x + idx * brick_w, start_y)
					if row_config.has("hp_override"):
						brick.hp = row_config["hp_override"]
						brick.max_hp = row_config["hp_override"]
					brick_container.add_child(brick)
		else:
			# 无空隙：紧密排列
			var start_x := (BalanceData.WORLD_WIDTH - col_count * brick_w) * 0.5 + brick_w * 0.5
			for col in range(col_count):
				var brick: Node2D = brick_scene.instantiate()
				brick.position = Vector2(start_x + col * brick_w, start_y)
				if row_config.has("hp_override"):
					brick.hp = row_config["hp_override"]
					brick.max_hp = row_config["hp_override"]
				brick_container.add_child(brick)
	
	current_row_index += 1

## 生成混合类型砖块行（一行多种砖块）
func _spawn_mixed_row(types_config: Array, brick_w: float, start_y: float, row_config: Dictionary) -> void:
	# 计算总砖块数
	var total_count: int = 0
	for type_cfg in types_config:
		total_count += type_cfg.get("count", 0)
	
	if total_count <= 0:
		return
	
	var slots: int = row_config.get("slots", total_count)  # slots 为空位总数
	var use_gaps: bool = slots > total_count
	
	# 构建砖块类型列表（展开所有砖块）
	var brick_list: Array[String] = []
	for type_cfg in types_config:
		var brick_type: String = type_cfg.get("type", "normal")
		var count: int = type_cfg.get("count", 0)
		for i in range(count):
			brick_list.append(brick_type)
	
	if use_gaps:
		# 有空隙：随机打乱砖块顺序，在 slots 个位置中分配
		brick_list.shuffle()
		var layout := _generate_layout(slots, total_count)
		var start_x := (BalanceData.WORLD_WIDTH - slots * brick_w) * 0.5 + brick_w * 0.5
		var brick_idx: int = 0
		for idx in range(slots):
			if layout[idx]:  # true = 放砖块
				var brick_type: String = brick_list[brick_idx]
				var scene_path: String = BRICK_SCENES.get(brick_type, BRICK_SCENES["normal"])
				var brick: Node2D = load(scene_path).instantiate()
				brick.position = Vector2(start_x + idx * brick_w, start_y)
				if row_config.has("hp_override"):
					brick.hp = row_config["hp_override"]
					brick.max_hp = row_config["hp_override"]
				brick_container.add_child(brick)
				brick_idx += 1
	else:
		# 无空隙：紧密排列
		var start_x := (BalanceData.WORLD_WIDTH - total_count * brick_w) * 0.5 + brick_w * 0.5
		var current_col: int = 0
		for type_cfg in types_config:
			var brick_type: String = type_cfg.get("type", "normal")
			var count: int = type_cfg.get("count", 0)
			var scene_path: String = BRICK_SCENES.get(brick_type, BRICK_SCENES["normal"])
			var brick_scene := load(scene_path)
			for i in range(count):
				var brick: Node2D = brick_scene.instantiate()
				brick.position = Vector2(start_x + current_col * brick_w, start_y)
				if row_config.has("hp_override"):
					brick.hp = row_config["hp_override"]
					brick.max_hp = row_config["hp_override"]
				brick_container.add_child(brick)
				current_col += 1

## 生成槽位布局：在 total_slots 个位置中随机分配 brick_count 个砖块
## 返回 bool 数组，true = 放砖块，false = 空隙
func _generate_layout(total_slots: int, brick_count: int) -> Array[bool]:
	var layout: Array[bool] = []
	layout.resize(total_slots)
	# 先全部填空
	for i in range(total_slots):
		layout[i] = false
	# 随机选 brick_count 个位置放砖块
	var positions: Array[int] = []
	for i in range(total_slots):
		positions.append(i)
	positions.shuffle()
	for i in range(mini(brick_count, total_slots)):
		layout[positions[i]] = true
	return layout

## 下压速度递增（每 30 秒增加）
func _update_push_speed_increment(delta: float) -> void:
	push_speed_increment_timer += delta
	if push_speed_increment_timer >= 30.0:
		push_speed_increment_timer = 0.0
		push_speed += BalanceData.BRICK_PUSH_SPEED_INCREMENT

## 球碰到底线（安全兜底：防止突发 bug 导致球卡住）
## 保底线是物理实体，正常情况下球会被物理引擎自然反弹
## 此回调仅作为安全网，不扣球数、不触发 Game Over
func _on_ball_hit_bottom() -> void:
	# 仅做安全检查，不做任何惩罚
	pass

## 重新生成球（球掉落后）
func _respawn_ball() -> void:
	if ball and is_instance_valid(ball):
		ball.is_launched = false
		ball.direction = Vector2(0, -1)
		ball.global_position = Vector2(paddle.global_position.x, paddle.global_position.y - 30.0)
		GameManager.change_state(GameManager.GameState.PREPARING)

## 砖块被击碎（仅用于统计，关卡推进由时间驱动）
func _on_brick_destroyed(_brick: Node, _exp: int) -> void:
	pass

## Boss 被击败
func _on_boss_defeated(_boss: Node) -> void:
	current_boss = null

## 推进到下一关（通关时调用）
func _advance_to_next_level() -> void:
	current_level_index += 1
	if current_level_index >= level_data_list.size():
		GameManager.end_game(true)
		return
	
	current_level_data = level_data_list[current_level_index]
	current_row_index = 0
	_notify_stage_changed()
	_try_spawn_boss()

## 通知 HUD 关卡变化
func _notify_stage_changed() -> void:
	var stage_name := ""
	if current_level_data is LevelData:
		stage_name = (current_level_data as LevelData).level_name
	else:
		stage_name = "关卡 %d" % (current_level_index + 1)
	EventBus.stage_changed.emit(current_level_index + 1, stage_name)

## 重置 Bonus Brick 生成计时器
func _reset_bonus_brick_timer() -> void:
	bonus_brick_interval = randf_range(
		BalanceData.BONUS_BRICK_SPAWN_INTERVAL_MIN,
		BalanceData.BONUS_BRICK_SPAWN_INTERVAL_MAX
	)
	bonus_brick_timer = 0.0

## Bonus Brick 生成计时
func _update_bonus_brick_spawn(delta: float) -> void:
	bonus_brick_timer += delta
	if bonus_brick_timer >= bonus_brick_interval:
		bonus_brick_timer = 0.0
		bonus_brick_interval = randf_range(
			BalanceData.BONUS_BRICK_SPAWN_INTERVAL_MIN,
			BalanceData.BONUS_BRICK_SPAWN_INTERVAL_MAX
		)
		_spawn_bonus_brick()

## 生成 Bonus Brick
func _spawn_bonus_brick() -> void:
	var bonus_brick: StaticBody2D = BONUS_BRICK_SCENE.instantiate()
	var rand_x := randf_range(100.0, BalanceData.WORLD_WIDTH - 100.0)
	var rand_y := randf_range(100.0, 400.0)
	bonus_brick.position = Vector2(rand_x, rand_y)
	add_child(bonus_brick)

## 游戏开始回调
func _on_game_started() -> void:
	# 重置球计数
	ball_count = 1

## 初始球数量加成（来自局外升级）
func _on_meta_start_balls_changed(extra_balls: int) -> void:
	for i in range(extra_balls):
		_spawn_extra_ball(i, extra_balls)
	ball_count += extra_balls

## 生成额外的球（局外升级触发）
func _spawn_extra_ball(index: int, total: int) -> CharacterBody2D:
	var new_ball: CharacterBody2D = BALL_SCENE.instantiate()
	# 位置在挡板上方，横向均匀分布
	var spacing := BalanceData.WORLD_WIDTH / (total + 1)
	var x_pos := spacing * (index + 1)
	new_ball.global_position = Vector2(x_pos, paddle.global_position.y - 30.0)
	new_ball.is_split_ball = false
	# 复制主球的伤害属性
	if ball and is_instance_valid(ball):
		new_ball.damage_calc.damage = ball.damage_calc.damage
		new_ball.damage_calc.speed = ball.damage_calc.speed
		new_ball.damage_calc.size = ball.damage_calc.size
		new_ball.damage_calc.crit_chance = ball.damage_calc.crit_chance
		new_ball.damage_calc.crit_multiplier = ball.damage_calc.crit_multiplier
		new_ball.damage_calc.pierce = ball.damage_calc.pierce
		new_ball.damage_calc.reflect_bonus = ball.damage_calc.reflect_bonus
		new_ball.damage_calc.split_count = ball.damage_calc.split_count
		new_ball.damage_calc.fire_damage = ball.damage_calc.fire_damage
		new_ball.damage_calc.fire_duration = ball.damage_calc.fire_duration
	ball_container.add_child(new_ball)
	# 自动发射，方向稍微偏移
	var angle := deg_to_rad(randf_range(-15.0, 15.0))
	new_ball.direction = Vector2(sin(angle), -cos(angle)).normalized()
	new_ball.is_launched = true
	return new_ball

## 检查并显示待选的 Build 选择界面
func _check_pending_build_selection() -> void:
	var builds := BuildSystem.consume_pending_options()
	if builds.is_empty():
		return
	# 确保状态正确
	if GameManager.current_state == GameManager.GameState.BUILD_SELECT:
		EventBus.show_build_selection.emit(builds)
