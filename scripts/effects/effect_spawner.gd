## 特效管理器（Autoload）
## 集中管理所有特效的生成，预加载场景避免运行时开销
extends Node

## 预加载特效场景
const BRICK_BREAK_PARTICLES := preload("res://scenes/effects/brick_break_particles.tscn")
const HIT_FLASH := preload("res://scenes/effects/hit_flash.tscn")
const DAMAGE_NUMBER := preload("res://scenes/effects/damage_number.tscn")
const SHIELD_BREAK_PARTICLES := preload("res://scenes/effects/shield_break_particles.tscn")
const REGEN_PARTICLES := preload("res://scenes/effects/regen_particles.tscn")

func _ready() -> void:
	# 连接伤害飘字信号
	EventBus.show_damage_number.connect(spawn_damage_number)

## 砖块类型对应的碎裂粒子颜色
const BRICK_COLORS: Dictionary = {
	"normal": Color(1.0, 1.0, 1.0, 1.0),
	"hard": Color(0.6, 0.6, 0.7, 1.0),
	"split": Color(0.8, 1.0, 0.8, 1.0),
	"regen": Color(0.3, 1.0, 0.3, 1.0),
	"ghost": Color(0.7, 0.7, 1.0, 0.6),
	"shield": Color(0.4, 0.7, 1.0, 1.0),
	"haste": Color(1.0, 1.0, 0.3, 1.0),
	"curse": Color(0.6, 0.2, 0.8, 1.0),
}

## 生成砖块碎裂粒子
func spawn_brick_break(pos: Vector2, brick_type: String = "normal") -> void:
	var particles := BRICK_BREAK_PARTICLES.instantiate() as CPUParticles2D
	particles.global_position = pos
	particles.color = BRICK_COLORS.get(brick_type, Color.WHITE)
	# 添加到游戏世界场景
	var game_world := get_tree().get_first_node_in_group("game_world")
	if game_world:
		game_world.add_child(particles)
	else:
		get_tree().current_scene.add_child(particles)
	# 开始发射并设置自动移除
	particles.emitting = true
	particles.finished.connect(particles.queue_free)

## 生成碰撞闪光
func spawn_hit_flash(pos: Vector2) -> void:
	var flash := HIT_FLASH.instantiate()
	flash.global_position = pos
	get_tree().current_scene.add_child(flash)

## 生成伤害飘字
func spawn_damage_number(pos: Vector2, damage: float, is_crit: bool) -> void:
	var label := DAMAGE_NUMBER.instantiate()
	label.global_position = pos
	# 设置伤害数字和样式
	label.get_node("Label").text = str(int(damage))
	if is_crit:
		label.get_node("Label").add_theme_color_override("font_color", Color(1.0, 0.3, 0.3, 1.0))
		label.get_node("Label").add_theme_font_size_override("font_size", 18)
	else:
		label.get_node("Label").add_theme_color_override("font_color", Color(1.0, 1.0, 0.5, 1.0))
		label.get_node("Label").add_theme_font_size_override("font_size", 14)
	get_tree().current_scene.add_child(label)

## 生成护盾碎裂粒子
func spawn_shield_break(pos: Vector2) -> void:
	var particles := SHIELD_BREAK_PARTICLES.instantiate()
	particles.global_position = pos
	var game_world := get_tree().get_first_node_in_group("game_world")
	if game_world:
		game_world.add_child(particles)
	else:
		get_tree().current_scene.add_child(particles)
	particles.emitting = true
	particles.finished.connect(particles.queue_free)

## 生成再生回血粒子
func spawn_regen(pos: Vector2) -> void:
	var particles := REGEN_PARTICLES.instantiate()
	particles.global_position = pos
	var game_world := get_tree().get_first_node_in_group("game_world")
	if game_world:
		game_world.add_child(particles)
	else:
		get_tree().current_scene.add_child(particles)
	particles.emitting = true
	particles.finished.connect(particles.queue_free)
