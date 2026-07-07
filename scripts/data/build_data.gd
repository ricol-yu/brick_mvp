## Build 数据结构定义（Godot Resource）
## 每个 Build 存储为 .tres 文件，可在编辑器 Inspector 中直接编辑
class_name BuildData
extends Resource

## Build ID（唯一标识，格式：分类前缀+功能名，如 "ball_split"）
@export var id: String = ""

## 显示名称
@export var name: String = ""

## 分类（Ball / Paddle / Safety）
@export_enum("Ball", "Paddle", "Safety") var type: String = "Ball"

## 稀有度（Common / Rare / Epic / Legendary）
@export_enum("Common", "Rare", "Epic", "Legendary") var rarity: String = "Common"

## 玩家可见描述
@export_multiline var description: String = ""

## 效果参数（数值平衡可后续调整）
@export var effect: Dictionary = {}

## 最大等级（满级后不再出现在候选中）
@export var max_level: int = 1

## 标签列表（用于 Tag 系统联动检测）
@export var tags: Array[String] = []

## 互斥标签（同一升级选项中不出现含相同互斥标签的 Build）
@export var exclusive_tags: Array[String] = []

## 解锁条件（如 "Lv3" 表示玩家等级 ≥3 时才可出现）
@export var unlock_condition: String = ""

## 图标纹理（在 UI 中显示的图标）
@export var icon: Texture2D = null

## 当前等级（运行时使用，不序列化到 .tres）
var current_level: int = 0

## 是否已满级
func is_max_level() -> bool:
	return current_level >= max_level

## 升级一级
func level_up() -> void:
	if not is_max_level():
		current_level += 1

## 获取当前等级效果值（按等级缩放）
func get_effect_value(key: String) -> Variant:
	if not effect.has(key):
		return null
	var base_value = effect[key]
	if base_value is float or base_value is int:
		# 每级增加 20% 效果（简化设计）
		return base_value * (1.0 + 0.2 * (current_level - 1))
	return base_value

## 获取稀有度颜色
func get_rarity_color() -> Color:
	match rarity:
		"Common":
			return Color.WHITE
		"Rare":
			return Color(0.3, 0.6, 1.0)  # 蓝色
		"Epic":
			return Color(0.7, 0.3, 1.0)  # 紫色
		"Legendary":
			return Color(1.0, 0.8, 0.2)  # 金色
	return Color.WHITE
