## 再生砖 — 每 3 秒回复 1 HP，必须集中火力击碎
extends BrickBase

## 回复间隔（秒）
const REGEN_INTERVAL: float = 3.0
## 每次回复量
const REGEN_AMOUNT: float = 1.0

## 回复计时器
var regen_timer: float = 0.0
## 是否正在回复闪烁
var is_regen_flash: bool = false
var regen_flash_timer: float = 0.0
const REGEN_FLASH_DURATION: float = 0.3

func _ready() -> void:
	hp = BalanceData.BRICK_NORMAL_HP * 2  # 再生砖初始 HP 稍高
	max_hp = hp
	super._ready()

func _process(delta: float) -> void:
	super._process(delta)
	
	# 回复闪烁
	if is_regen_flash:
		regen_flash_timer -= delta
		if regen_flash_timer <= 0:
			is_regen_flash = false
			if sprite:
				sprite.modulate = _base_color
	
	# 每 3 秒回复 1 HP
	if hp < max_hp and hp > 0:
		regen_timer += delta
		if regen_timer >= REGEN_INTERVAL:
			regen_timer = 0.0
			hp = minf(hp + REGEN_AMOUNT, max_hp)
			_update_visual()
			# 绿色闪烁提示回复
			is_regen_flash = true
			regen_flash_timer = REGEN_FLASH_DURATION
			if sprite:
				sprite.modulate = Color(0.3, 1.2, 0.3, 1.0)
			# 生成再生回血粒子特效
			EffectSpawner.spawn_regen(global_position)

func get_brick_type() -> String:
	return "regen"
