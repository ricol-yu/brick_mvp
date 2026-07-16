## 幽灵砖 — 实体态（1.5s）可击中 → 灵体态（1.5s）球直接穿过
extends BrickBase

## 相位周期（秒）
const PHASE_DURATION: float = 1.5

## 当前是否为实体态
var is_phase_solid: bool = true
## 相位计时器
var phase_timer: float = 0.0

func _ready() -> void:
	hp = BalanceData.BRICK_NORMAL_HP
	super._ready()

func _process(delta: float) -> void:
	super._process(delta)
	
	phase_timer += delta
	if phase_timer >= PHASE_DURATION:
		phase_timer = 0.0
		is_phase_solid = not is_phase_solid
		_update_phase_visual()

## 更新相位视觉
func _update_phase_visual() -> void:
	if sprite:
		if is_phase_solid:
			sprite.modulate = _base_color
			# 恢复碰撞
			if collision_shape:
				collision_shape.disabled = false
		else:
			# 灵体态：半透明
			sprite.modulate = Color(_base_color.r, _base_color.g, _base_color.b, 0.3)
			# 禁用碰撞，球直接穿过
			if collision_shape:
				collision_shape.disabled = true

func get_brick_type() -> String:
	return "ghost"
