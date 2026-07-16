## 球实体脚本
## 负责球的移动、反弹物理、碰撞检测
extends CharacterBody2D

## 球是否已发射
var is_launched: bool = false

## 球的运动方向（归一化）
var direction: Vector2 = Vector2(0, -1)

## 伤害计算器
var damage_calc: BallDamageCalc = BallDamageCalc.new()

## 当前剩余的穿透次数
var remaining_pierce: int = 0

## 球半径（像素）
@export var ball_radius: float = 8.0

## 是否为分裂产生的子球
var is_split_ball: bool = false

## 减速诅咒状态
var is_cursed_slow: bool = false
var curse_slow_timer: float = 0.0
## 移动速度倍率（仅影响移动，不影响伤害）
var move_speed_multiplier: float = 1.0

## 子节点引用
@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var trail_particles: CPUParticles2D = $TrailParticles

func _ready() -> void:
	add_to_group("ball")
	_update_collision_shape()
	EventBus.ball_launched.connect(_on_ball_launched)
	EventBus.build_applied.connect(_on_build_applied)
	# 初始化拖尾粒子为关闭状态
	if trail_particles:
		trail_particles.emitting = false

func _physics_process(delta: float) -> void:
	if not is_launched:
		# 未发射时跟随挡板
		_follow_paddle(delta)
		return
	
	if GameManager.current_state != GameManager.GameState.PLAYING:
		return
	
	# 减速诅咒计时
	if is_cursed_slow:
		curse_slow_timer -= delta
		if curse_slow_timer <= 0:
			is_cursed_slow = false
			move_speed_multiplier = 1.0
			# 恢复原始颜色
			if sprite:
				sprite.modulate = Color(1.0, 0.9, 0.3, 1.0)
			# 恢复拖尾粒子颜色
			if trail_particles:
				trail_particles.color = Color(1.0, 0.9, 0.3, 0.6)
	
	# 移动球（move_speed_multiplier 仅影响移动速度，不影响伤害）
	var move_distance := damage_calc.speed * move_speed_multiplier * delta
	var motion := direction * move_distance
	var collision := move_and_collide(motion)
	
	if collision:
		_handle_collision(collision)

## 跟随挡板（未发射时）
func _follow_paddle(_delta: float) -> void:
	var paddle := get_tree().get_first_node_in_group("paddle") as Node2D
	if paddle:
		global_position = Vector2(paddle.global_position.x, paddle.global_position.y - 30.0)

## 发射球
func launch(launch_direction: Vector2 = Vector2(0, -1)) -> void:
	is_launched = true
	direction = launch_direction.normalized()
	# 开启拖尾粒子
	if trail_particles:
		trail_particles.emitting = true

## 处理碰撞
func _handle_collision(collision: KinematicCollision2D) -> void:
	var collider := collision.get_collider()
	var normal := collision.get_normal()
	
	if collider == null:
		# 碰撞到墙壁，简单反弹
		direction = direction.bounce(normal)
		EventBus.ball_bounced.emit("wall", global_position)
		return
	
	var collider_type := ""
	var reflect_multiplier := 1.0
	
	if collider.is_in_group("paddle"):
		collider_type = "paddle"
		reflect_multiplier = _handle_paddle_collision(collider, normal)
		# 保底线碰撞：只反弹，不触发分裂
		if collider.is_in_group("bottom_line"):
			AudioManager.play_sfx("ball_bounce")
			EventBus.ball_hit_bottom.emit()
			EventBus.ball_bounced.emit("bottom_line", global_position)
			return
		# 球分裂：碰撞真实挡板时触发
		AudioManager.play_sfx("ball_paddle")
		_try_split_balls()
		# 挡板反弹方向已由 _handle_paddle_collision 设置，直接返回
		EventBus.ball_bounced.emit(collider_type, global_position)
		return
	elif collider.is_in_group("bricks"):
		collider_type = "brick"
		# 穿透检查：如果有穿透次数，不反弹而是穿过砖块
		if remaining_pierce > 0:
			remaining_pierce -= 1
			_handle_brick_collision(collider, reflect_multiplier)
			EventBus.ball_bounced.emit("brick_pierce", global_position)
			return  # 不反弹，直接穿过
		_handle_brick_collision(collider, reflect_multiplier)
		# 没有穿透时更新穿透值（为下一次碰撞准备）
		remaining_pierce = damage_calc.pierce
	elif collider.is_in_group("boss"):
		collider_type = "boss"
		AudioManager.play_sfx("ball_boss")
		_handle_boss_collision(collider, reflect_multiplier)
		# Boss 碰撞也可以使用穿透
		if remaining_pierce > 0:
			remaining_pierce -= 1
			EventBus.ball_bounced.emit("boss_pierce", global_position)
			return
	elif collider.is_in_group("bonus_brick"):
		collider_type = "bonus_brick"
		_handle_bonus_brick_collision(collider, reflect_multiplier)
	else:
		collider_type = "wall"
		AudioManager.play_sfx("ball_bounce")
	
	# 反弹方向
	direction = direction.bounce(normal)
	# 碰撞闪光特效
	EffectSpawner.spawn_hit_flash(global_position)
	EventBus.ball_bounced.emit(collider_type, global_position)

## 处理挡板碰撞 - 返回反弹倍率
func _handle_paddle_collision(paddle_node: Node2D, _normal: Vector2) -> float:
	# 保底线视为无限宽挡板，碰撞位置直接映射到角度
	if paddle_node.is_in_group("bottom_line"):
		var half_world := BalanceData.WORLD_WIDTH * 0.5
		var hit_offset := (global_position.x - paddle_node.global_position.x) / half_world
		hit_offset = clampf(hit_offset, -1.0, 1.0)
		var angle := hit_offset * deg_to_rad(60.0)
		direction = Vector2(sin(angle), -cos(angle)).normalized()
		return 1.0
	
	# 基于碰撞位置计算反弹角度（经典 Arkanoid 式）
	var paddle_width := paddle_node.get("paddle_width") as float if paddle_node.has_method("get") else BalanceData.PADDLE_BASE_WIDTH
	if paddle_width == 0.0:
		paddle_width = BalanceData.PADDLE_BASE_WIDTH
	
	var hit_offset := (global_position.x - paddle_node.global_position.x) / (paddle_width * 0.5)
	hit_offset = clampf(hit_offset, -1.0, 1.0)
	
	# 将偏移量映射到反弹角度（-60° 到 +60°）
	var angle := hit_offset * deg_to_rad(60.0)
	direction = Vector2(sin(angle), -cos(angle)).normalized()
	
	# 检测 Perfect Zone（中心 20% 区域）
	var is_perfect := absf(hit_offset) <= BalanceData.PADDLE_PERFECT_ZONE_RATIO
	if is_perfect:
		GameManager.run_stats["perfect_bounces"] += 1
		return BalanceData.PADDLE_PERFECT_MULTIPLIER
	
	return 1.0

## 处理砖块碰撞
func _handle_brick_collision(brick: Node, reflect_multiplier: float) -> void:
	if not brick.has_method("take_damage"):
		return
	
	# 计算伤害
	var result := damage_calc.calc_brick_damage(reflect_multiplier)
	var final_damage: float = result["damage"]
	var is_crit: bool = result["is_crit"]
	
	# 显示伤害数字
	EventBus.show_damage_number.emit(brick.global_position, final_damage, is_crit)
	
	# 扣血
	brick.take_damage(final_damage)
	
	# 火焰 DoT：如果球有火焰伤害，点燃砖块
	if damage_calc.fire_damage > 0 and brick.has_method("start_burning"):
		brick.start_burning(damage_calc.fire_damage, maxf(damage_calc.fire_duration, 2.0))
	
	# 记录总伤害
	GameManager.run_stats["total_damage_dealt"] += final_damage

## 处理 Boss 碰撞
func _handle_boss_collision(boss: Node, reflect_multiplier: float) -> void:
	if not boss.has_method("take_damage"):
		return
	var result := damage_calc.calc_brick_damage(reflect_multiplier)
	boss.take_damage(result["damage"])
	EventBus.show_damage_number.emit(boss.global_position, result["damage"], result["is_crit"])
	GameManager.run_stats["total_damage_dealt"] += result["damage"]

## 处理 Bonus Brick 碰撞
func _handle_bonus_brick_collision(bonus_brick: Node, reflect_multiplier: float) -> void:
	if not bonus_brick.has_method("take_damage"):
		return
	var result := damage_calc.calc_brick_damage(reflect_multiplier)
	bonus_brick.take_damage(result["damage"])

## 处理底线碰撞（保留供外部调用）
func _handle_bottom_collision() -> void:
	EventBus.ball_hit_bottom.emit()

## 尝试分裂球（挡板碰撞时触发）
func _try_split_balls() -> void:
	if damage_calc.split_count <= 0:
		return
	if is_split_ball:
		return  # 子球不再分裂，防止无限分裂
	
	var game_world := get_tree().get_first_node_in_group("game_world") as Node2D
	if not game_world:
		# 尝试通过父节点获取
		game_world = get_parent()
	
	var ball_container := game_world.get_node_or_null("BallContainer") as Node2D
	if not ball_container:
		return
	
	for i in range(damage_calc.split_count):
		var split_ball := _create_split_ball(i, damage_calc.split_count)
		if split_ball:
			ball_container.add_child(split_ball)

## 创建分裂球
func _create_split_ball(index: int, total: int) -> CharacterBody2D:
	var ball_scene := preload("res://scenes/entities/ball/ball.tscn")
	var new_ball: CharacterBody2D = ball_scene.instantiate()
	
	# 位置稍微偏移
	var offset_angle := deg_to_rad(15.0 + 10.0 * index)
	if index % 2 == 1:
		offset_angle = -offset_angle
	
	new_ball.global_position = global_position + Vector2(5.0 * (index + 1), 0)
	new_ball.is_split_ball = true
	new_ball.is_launched = true
	
	# 方向偏移
	var new_direction := direction.rotated(offset_angle).normalized()
	new_ball.direction = new_direction
	
	# 复制伤害计算器属性
	new_ball.damage_calc.damage = damage_calc.damage
	new_ball.damage_calc.speed = damage_calc.speed
	new_ball.damage_calc.size = damage_calc.size
	new_ball.damage_calc.crit_chance = damage_calc.crit_chance
	new_ball.damage_calc.crit_multiplier = damage_calc.crit_multiplier
	new_ball.damage_calc.pierce = damage_calc.pierce
	new_ball.damage_calc.reflect_bonus = damage_calc.reflect_bonus
	# 子球不再分裂
	new_ball.damage_calc.split_count = 0
	new_ball.remaining_pierce = remaining_pierce
	
	return new_ball

## 更新碰撞形状大小
func _update_collision_shape() -> void:
	if collision_shape and collision_shape.shape is CircleShape2D:
		(collision_shape.shape as CircleShape2D).radius = ball_radius * damage_calc.size
	if sprite:
		sprite.scale = Vector2.ONE * damage_calc.size

func _on_ball_launched() -> void:
	if not is_split_ball:
		launch(Vector2(randf_range(-0.3, 0.3), -1.0))

func _on_build_applied(build_data: Resource) -> void:
	if build_data is BuildData:
		damage_calc.apply_build_effect(build_data)
		_update_collision_shape()

## 施加减速诅咒（仅降低移动速度，不影响伤害）
func apply_curse_slow(multiplier: float, duration: float) -> void:
	if not is_launched:
		return
	is_cursed_slow = true
	move_speed_multiplier = multiplier
	curse_slow_timer = duration
	# 视觉反馈：球变暗紫色
	if sprite:
		sprite.modulate = Color(0.5, 0.2, 0.8, 1.0)
	# 拖尾粒子也变暗紫色
	if trail_particles:
		trail_particles.color = Color(0.5, 0.2, 0.8, 0.6)
