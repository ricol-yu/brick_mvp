## Tag 系统（非 Autoload，由 BuildSystem 调用）
## 管理 Build 标签、流派检测、联动效果触发
class_name TagSystem
extends RefCounted

## 玩家已选择的 Build 标签计数 { "tag_name": count }
var tag_counts: Dictionary = {}

## 已激活的 Build 列表
var active_builds: Array[BuildData] = []

## 记录玩家当前的主要流派标签（出现次数最多的 Tag）
var primary_build_path: String = ""

## 添加一个 Build 的标签
func add_build_tags(build_data: BuildData) -> void:
	active_builds.append(build_data)
	for tag in build_data.tags:
		if not tag_counts.has(tag):
			tag_counts[tag] = 0
		tag_counts[tag] += 1
	_update_primary_path()

## 获取某个 Tag 的计数
func get_tag_count(tag: String) -> int:
	return tag_counts.get(tag, 0)

## 判断玩家是否拥有某个 Tag（至少 1 个）
func has_tag(tag: String) -> bool:
	return get_tag_count(tag) > 0

## 判断是否形成流派（同 Tag ≥ 2 个）
func is_build_path(tag: String) -> bool:
	return get_tag_count(tag) >= 2

## 获取所有已形成流派的 Tag
func get_active_paths() -> Array[String]:
	var paths: Array[String] = []
	for tag in tag_counts:
		if tag_counts[tag] >= 2:
			paths.append(tag)
	return paths

## 检查两个 Build 是否可以联动
func check_synergy(build_a: BuildData, build_b: BuildData) -> bool:
	# 简化联动检测：共享功能标签或元素标签即视为可联动
	for tag_a in build_a.tags:
		if build_b.tags.has(tag_a):
			return true
	# 检查特定的联动组合
	if build_a.tags.has("Split") and build_b.tags.has("Lightning"):
		return true
	if build_b.tags.has("Split") and build_a.tags.has("Lightning"):
		return true
	if build_a.tags.has("Fire") and build_b.tags.has("Explosion"):
		return true
	if build_b.tags.has("Fire") and build_a.tags.has("Explosion"):
		return true
	if build_a.tags.has("Size") and build_b.tags.has("Pierce"):
		return true
	if build_b.tags.has("Size") and build_a.tags.has("Pierce"):
		return true
	return false

## 检查新 Build 是否与已有 Build 互斥
func is_exclusive_with_active(build_data: BuildData) -> bool:
	for existing in active_builds:
		for ex_tag in build_data.exclusive_tags:
			if existing.tags.has(ex_tag) or existing.exclusive_tags.has(ex_tag):
				return true
	return false

## 更新主要流派
func _update_primary_path() -> void:
	var max_count := 0
	primary_build_path = ""
	for tag in tag_counts:
		if tag_counts[tag] > max_count:
			max_count = tag_counts[tag]
			primary_build_path = tag

## 获取应被加成的 Tag 列表（用于 Build 池权重调整）
func get_favored_tags() -> Array[String]:
	return get_active_paths()

## 重置（新一局开始时）
func reset() -> void:
	tag_counts.clear()
	active_builds.clear()
	primary_build_path = ""
