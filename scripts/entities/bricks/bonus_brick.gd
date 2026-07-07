## Bonus Brick 脚本
## 特殊砖块，被击碎后直接给予 Build 选项（不给经验）
extends StaticBody2D

## HP
@export var hp: float = 1.0
@export var max_hp: float = 1.0

## 存在时间（秒）
var lifetime: float = 0.0
var max_lifetime: float = 10.0

## 受击闪烁
var flash_timer: float = 0.0
const FLASH_DURATION := 0.1

## 子节点引用
@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	add_to_group("bonus_brick")
	collision_layer = 64  # layer 7 (bonus_brick)
	collision_mask = 4    # layer 3 (ball)
	max_lifetime = randf_range(BalanceData.BONUS_BRICK_LIFETIME_MIN, BalanceData.BONUS_BRICK_LIFETIME_MAX)
	
	# 创建占位符纹理
	_create_placeholder_texture()
	
	# 设置金色外观
	if sprite:
		sprite.modulate = Color(1.0, 0.85, 0.2, 1.0)

## 创建占位符纹理（白色矩形）
func _create_placeholder_texture() -> void:
	if sprite and sprite.texture == null:
		var img := Image.create(64, 32, false, Image.FORMAT_RGBA8)
		img.fill(Color.WHITE)
		sprite.texture = ImageTexture.create_from_image(img)

func _process(delta: float) -> void:
	# 闪烁
	if flash_timer > 0:
		flash_timer -= delta
		if flash_timer <= 0:
			if sprite:
				sprite.modulate = Color(1.0, 0.85, 0.2, 1.0)
	
	# 生命周期
	lifetime += delta
	# 最后 2 秒闪烁提示即将消失
	if lifetime > max_lifetime - 2.0:
		var blink := sin(lifetime * 10.0) > 0
		if sprite:
			sprite.modulate = Color(1.0, 0.5, 0.1, 1.0) if blink else Color(0.3, 0.3, 0.1, 0.5)
	
	if lifetime >= max_lifetime:
		queue_free()

## 受到伤害
func take_damage(damage: float) -> void:
	hp -= damage
	flash_timer = FLASH_DURATION
	if sprite:
		sprite.modulate = Color(3.0, 3.0, 3.0, 1.0)
	
	if hp <= 0:
		_on_destroyed()

## 被击碎 - 触发 Build 选择
func _on_destroyed() -> void:
	# 创建一个空的 BuildData 作为标记（实际 Build 选项由 BuildSystem 生成）
	var dummy := BuildData.new()
	dummy.id = "bonus_brick_reward"
	EventBus.bonus_brick_destroyed.emit(dummy)
	
	# 触发 Build 选择
	GameManager.change_state(GameManager.GameState.BUILD_SELECT)
	var builds := BuildSystem.generate_build_options(3)
	EventBus.show_build_selection.emit(builds)
	
	queue_free()
