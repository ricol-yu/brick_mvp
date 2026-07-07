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

## 砖块尺寸
@export var brick_width: float = 64.0
@export var brick_height: float = 32.0

## 受击闪烁时间
const FLASH_DURATION := 0.1

## 闪烁计时器
var flash_timer: float = 0.0

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
@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var hp_label: Label = $HPLabel if has_node("HPLabel") else null

func _ready() -> void:
	add_to_group("bricks")
	max_hp = hp
	_create_placeholder_texture()
	# 保存场景设置的原始颜色
	if sprite:
		_base_color = sprite.modulate
	_update_visual()

## 创建占位符纹理（白色矩形）
func _create_placeholder_texture() -> void:
	if sprite and sprite.texture == null:
		var w := int(brick_width)
		var h := int(brick_height)
		var img := Image.create(w, h, false, Image.FORMAT_RGBA8)
		img.fill(Color.WHITE)
		sprite.texture = ImageTexture.create_from_image(img)

func _process(delta: float) -> void:
	if flash_timer > 0:
		flash_timer -= delta
		if flash_timer <= 0:
			_stop_flash()
	
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
	
	EventBus.brick_hit.emit(self, damage)
	
	if hp <= 0:
		_on_destroyed()

## 砖块被击碎
func _on_destroyed() -> void:
	EventBus.brick_destroyed.emit(self, reward_exp)
	# 生成经验掉落（通过 ExpSystem 处理）
	queue_free()

## 开始闪烁效果
func _start_flash() -> void:
	flash_timer = FLASH_DURATION
	if sprite:
		sprite.modulate = Color(2.0, 2.0, 2.0, 1.0)  # 亮白色闪烁

## 停止闪烁
func _stop_flash() -> void:
	if sprite:
		# 恢复原始颜色（考虑 HP 比例）
		var hp_ratio := clampf(hp / max_hp, 0.0, 1.0) if max_hp > 0 else 1.0
		sprite.modulate = _base_color.darkened(1.0 - hp_ratio) if hp_ratio < 1.0 else _base_color

## 更新视觉（根据 HP 比例变色）
func _update_visual() -> void:
	if hp_label:
		if hp > 1.0:
			hp_label.text = str(ceili(hp))
			hp_label.visible = true
		else:
			hp_label.visible = false
	
	# 根据 HP 比例调整颜色深度
	if sprite and max_hp > 0:
		var hp_ratio := clampf(hp / max_hp, 0.0, 1.0)
		sprite.modulate = _base_color.darkened(1.0 - hp_ratio) if hp_ratio < 1.0 else _base_color

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
