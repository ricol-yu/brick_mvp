## 数值平衡常量（参照策划文档"数值策划"）
## 所有游戏数值在此集中管理，方便后续调整
class_name BalanceData
extends RefCounted

# ===================== 球基础属性 =====================
const BALL_BASE_DAMAGE: float = 1.0
const BALL_BASE_SPEED: float = 400.0     ## 像素/秒
const BALL_BASE_SIZE: float = 1.0
const BALL_BASE_CRIT_CHANCE: float = 0.0
const BALL_BASE_CRIT_MULTIPLIER: float = 2.0
const BALL_BASE_PIERCE: int = 0
const BALL_BASE_SPLIT_COUNT: int = 0

# ===================== 挡板基础属性 =====================
const PADDLE_BASE_MOVE_SPEED: float = 500.0  ## 像素/秒
const PADDLE_BASE_WIDTH: float = 120.0       ## 像素
const PADDLE_BASE_REFLECT_BONUS: float = 1.0
const PADDLE_PERFECT_ZONE_RATIO: float = 0.2 ## 中心 20% 区域为 Perfect Zone
const PADDLE_PERFECT_MULTIPLIER: float = 1.25

# ===================== 保底线基础属性 =====================
const SAFETY_REFLECT_MULTIPLIER: float = 0.8
const SAFETY_BONUS_CHANCE: float = 0.0

# ===================== 砖块基础属性 =====================
const BRICK_NORMAL_HP: float = 1.0
const BRICK_HARD_HP: float = 3.0          ## 坚硬砖（MVP 第二种砖）
const BRICK_BASE_EXP: int = 1
const BRICK_BASE_COIN: int = 0
const BRICK_BASE_WEIGHT: float = 1.0

# ===================== 升级经验需求（MVP简化） =====================
const EXP_TABLE: Array[int] = [
	5,   ## Lv1 → Lv2 需要 5 EXP
	10,  ## Lv2 → Lv3 需要 10 EXP
	20,  ## Lv3 → Lv4 需要 20 EXP
	35,  ## Lv4 → Lv5 需要 35 EXP
	55,  ## Lv5 → Lv6 需要 55 EXP（MVP 最高等级）
]
const MAX_LEVEL: int = 5  ## MVP 最高等级

# ===================== Build 稀有度概率 =====================
const RARITY_WEIGHTS: Dictionary = {
	"Common": 55.0,
	"Rare": 30.0,
	"Epic": 12.0,
	"Legendary": 3.0,
}

## 已有流派加成概率（同 Tag Build ≥2 个时提升 50%）
const TAG_FAVOR_BONUS: float = 1.5

# ===================== Boss 调度 =====================
const BOSS_SPAWN_INTERVAL_MIN: float = 90.0   ## 秒
const BOSS_SPAWN_INTERVAL_MAX: float = 120.0  ## 秒

# ===================== Bonus Brick =====================
const BONUS_BRICK_LIFETIME_MIN: float = 8.0   ## 存在最短时间（秒）
const BONUS_BRICK_LIFETIME_MAX: float = 12.0  ## 存在最长时间（秒）
const BONUS_BRICK_SPAWN_INTERVAL_MIN: float = 20.0
const BONUS_BRICK_SPAWN_INTERVAL_MAX: float = 40.0

# ===================== 砖块压力系统 =====================
const BRICK_PUSH_SPEED_INITIAL: float = 5.0    ## 初始下推速度（像素/秒）
const BRICK_PUSH_SPEED_INCREMENT: float = 1.0  ## 每 30 秒增加的速度
const BRICK_ROW_SPAWN_INTERVAL: float = 15.0   ## 每隔多少秒生成新行
const BOTTOM_LINE_Y: float = 650.0              ## 底线 Y 坐标（像素）

# ===================== 游戏世界尺寸 =====================
const WORLD_WIDTH: float = 1280.0
const WORLD_HEIGHT: float = 720.0
const WALL_THICKNESS: float = 20.0

# ===================== 伤害计算辅助 =====================
## 计算最终伤害
## 最终伤害 = 基础伤害 × 速度倍率 × 暴击倍率 × 反弹倍率
static func calculate_damage(
	base_damage: float,
	speed_multiplier: float,
	crit_chance: float,
	crit_multiplier: float,
	reflect_multiplier: float
) -> Dictionary:
	var is_crit := randf() <= crit_chance
	var crit_mult := crit_multiplier if is_crit else 1.0
	var final_damage := base_damage * speed_multiplier * crit_mult * reflect_multiplier
	return {
		"damage": final_damage,
		"is_crit": is_crit,
	}

## 获取升级所需累计经验
static func get_exp_for_level(level: int) -> int:
	if level <= 0 or level > EXP_TABLE.size():
		return 999999
	return EXP_TABLE[level - 1]
