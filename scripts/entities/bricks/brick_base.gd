## 砖块基类脚本
## 所有砖块类型的父类，处理 HP、受击、掉落经验
extends StaticBody2D
class_name BrickBase

## 砖块基础属性
@export var hp: float = BalanceData.BRICK_NORMAL_HP
@export var max_hp: float = BalanceData.BRICK_NORMAL_HP
@export var shield: float = 0.0
@export var reward_exp: int = BalanceData.BRICK_BASE_EXP
@export var reward_coin: int = BalanceData.BRICK_BASE_COIN

## 砖块尺寸（引用 BalanceData 集中配置）
@export var brick_width: float = BalanceData.BRICK_WIDTH
@export var brick_height: float = BalanceData.BRICK_HEIGHT

## 受击闪烁时间
const FLASH_DURATION := 0.1

## 受击音效冷却（秒）——同一砖块在此时间内不重复播放受击音
const HIT_SFX_COOLDOWN := 0.15

## 闪烁计时器
var flash_timer: float = 0.0

## 受击音效冷却计时
var _hit_sfx_cooldown: float = 0.0

## 原始颜色（场景设置的 modulate）
var _base_color: Color = Color.WHITE

## 火焰 DoT
var is_burning: bool = false
var burn_damage: float = 0.0
var burn_duration: float = 0.0
var burn_timer: float = 0.0
var burn_tick_interval: float = 0.5  ## 每次灼伤间隔
var burn_tick_timer: float = 0.0

## 子节点引用
@onready var sprite: Sprite2D = $Sprite2D if has_node("Sprite2D") else null
@onready var anim_sprite: AnimatedSprite2D = $AnimatedSprite2D if has_node("AnimatedSprite2D") else null
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var hp_label: Label = $HPLabel if has_node("HPLabel") else null

## 动画状态枚举
enum AnimState { IDLE, HIT, DEATH }
var current_anim_state: AnimState = AnimState.IDLE
## 动画是否已配置（子类在 _ready 中设置）
var _anim_configured: bool = false

func _ready() -> void:
	add_to_group("bricks")
	max_hp = hp
	# 保存场景设置的原始颜色
	if sprite:
		_base_color = sprite.modulate
	# 连接动画完成信号
	if anim_sprite:
		anim_sprite.animation_finished.connect(_on_anim_finished)
	_update_visual()

func _process(delta: float) -> void:
	if flash_timer > 0:
		flash_timer -= delta
		if flash_timer <= 0:
			_stop_flash()
	
	# 受击音效冷却
	if _hit_sfx_cooldown > 0:
		_hit_sfx_cooldown -= delta
	
	# 火焰 DoT
	if is_burning:
		burn_timer += delta
		burn_tick_timer += delta
		if burn_tick_timer >= burn_tick_interval:
			burn_tick_timer = 0.0
			take_damage(burn_damage)
			# 灼伤视觉：橙色闪烁
			if sprite:
				sprite.modulate = Color(1.5, 0.6, 0.1, 1.0)
		if burn_timer >= burn_duration:
			is_burning = false

## 受到伤害
func take_damage(damage: float) -> void:
	# 先扣护盾
	if shield > 0:
		var shield_damage := minf(shield, damage)
		shield -= shield_damage
		damage -= shield_damage
	
	if damage > 0:
		hp -= damage
	
	# 受击闪烁
	_start_flash()
	_update_visual()
	
	# 播放受击音效（带冷却，避免过于密集）
	if _hit_sfx_cooldown <= 0:
		AudioManager.play_sfx("brick_hit")
		_hit_sfx_cooldown = HIT_SFX_COOLDOWN
	
	EventBus.brick_hit.emit(self, damage)
	
	if hp <= 0:
		_on_destroyed()

## 砖块被击碎
func _on_destroyed() -> void:
	AudioManager.play_sfx("brick_destroy")
	# 生成碎裂粒子特效
	EffectSpawner.spawn_brick_break(global_position, get_brick_type())
	EventBus.brick_destroyed.emit(self, reward_exp)
	# 播放死亡动画（动画结束后 _on_anim_finished 会 queue_free）
	if _anim_configured:
		_play_anim_state(AnimState.DEATH)
		# 禁用碰撞，避免死亡动画期间仍参与物理
		if collision_shape:
			collision_shape.set_deferred("disabled", true)
	else:
		queue_free()

## 开始闪烁效果
func _start_flash() -> void:
	flash_timer = FLASH_DURATION
	# 优先使用动画系统
	if _anim_configured:
		_play_anim_state(AnimState.HIT)
		if anim_sprite:
			anim_sprite.modulate = Color(2.0, 2.0, 2.0, 1.0)
	elif sprite:
		sprite.modulate = Color(2.0, 2.0, 2.0, 1.0)  # 亮白色闪烁
	# 受击缩放弹性
	_start_hit_bounce()

## 停止闪烁
func _stop_flash() -> void:
	if _anim_configured:
		if anim_sprite:
			# 恢复原始颜色（考虑 HP 比例）
			var hp_ratio := clampf(hp / max_hp, 0.0, 1.0) if max_hp > 0 else 1.0
			anim_sprite.modulate = _base_color.darkened(1.0 - hp_ratio) if hp_ratio < 1.0 else _base_color
	elif sprite:
		# 恢复原始颜色（考虑 HP 比例）
		var hp_ratio := clampf(hp / max_hp, 0.0, 1.0) if max_hp > 0 else 1.0
		sprite.modulate = _base_color.darkened(1.0 - hp_ratio) if hp_ratio < 1.0 else _base_color

## 更新视觉（根据 HP 比例变色）
func _update_visual() -> void:
	# 隐藏 HP 标签（不再显示数字）
	if hp_label:
		hp_label.visible = false
	
	# 根据 HP 比例调整颜色深度
	var display_node = anim_sprite if anim_sprite else sprite
	if display_node and max_hp > 0:
		var hp_ratio := clampf(hp / max_hp, 0.0, 1.0)
		display_node.modulate = _base_color.darkened(1.0 - hp_ratio) if hp_ratio < 1.0 else _base_color

## 开始燃烧（由 ball.gd 调用）
func start_burning(damage: float, duration: float) -> void:
	is_burning = true
	burn_damage = damage
	burn_duration = duration
	burn_timer = 0.0
	burn_tick_timer = 0.0

## 获取砖块类型标识（子类覆盖）
func get_brick_type() -> String:
	return "normal"

## 受击缩放弹性动画
func _start_hit_bounce() -> void:
	var display_node = anim_sprite if anim_sprite else sprite
	if not display_node:
		return
	var tween := create_tween()
	tween.tween_property(display_node, "scale", Vector2(1.1, 1.1), 0.05)
	tween.tween_property(display_node, "scale", Vector2(1.0, 1.0), 0.05)

## 播放动画状态
func _play_anim_state(state: AnimState) -> void:
	if not anim_sprite or not _anim_configured:
		return
	current_anim_state = state
	match state:
		AnimState.IDLE:
			anim_sprite.play("idle")
		AnimState.HIT:
			anim_sprite.play("hit")
		AnimState.DEATH:
			anim_sprite.play("death")

## 动画播放完成回调
func _on_anim_finished() -> void:
	if current_anim_state == AnimState.HIT:
		_play_anim_state(AnimState.IDLE)
	elif current_anim_state == AnimState.DEATH:
		queue_free()
