## Build 池管理（非 Autoload，由 BuildSystem 调用）
## 负责从 Build 池中按规则抽选 Build
class_name BuildPool
extends RefCounted

## 所有可用 Build 的原始数据列表（从 .tres 文件加载）
var all_builds: Array[BuildData] = []

## 稀有度权重
var rarity_weights: Dictionary = BalanceData.RARITY_WEIGHTS.duplicate()

## 加载所有 Build 数据
func load_builds() -> void:
	all_builds.clear()
	var build_dirs := [
		"res://data/builds/ball_builds/",
		"res://data/builds/paddle_builds/",
		"res://data/builds/safety_builds/",
	]
	for dir_path in build_dirs:
		var dir := DirAccess.open(dir_path)
		if dir == null:
			continue
		dir.list_dir_begin()
		var file_name := dir.get_next()
		while file_name != "":
			if file_name.ends_with(".tres"):
				var build := load(dir_path + file_name) as BuildData
				if build:
					all_builds.append(build)
			file_name = dir.get_next()
		dir.list_dir_end()

## 从 Build 池中抽选指定数量的 Build
## 规则：满级排除、互斥过滤、已有流派加成
func select_builds(
	count: int,
	tag_system: TagSystem,
	player_level: int
) -> Array[BuildData]:
	var candidates := _get_eligible_builds(tag_system, player_level)
	var selected: Array[BuildData] = []
	
	for i in range(count):
		if candidates.is_empty():
			break
		var build := _weighted_random_pick(candidates, tag_system)
		if build:
			selected.append(build)
			# 移除已选 Build 的相同 ID，避免重复
			candidates = candidates.filter(func(b): return b.id != build.id)
	
	return selected

## 获取符合资格的 Build 列表
func _get_eligible_builds(tag_system: TagSystem, player_level: int) -> Array[BuildData]:
	var eligible: Array[BuildData] = []
	for build in all_builds:
		# 规则 1：满级 Build 不出现
		if build.is_max_level():
			continue
		# 规则 2：互斥 Build 不共存
		if build.exclusive_tags.size() > 0 and tag_system.is_exclusive_with_active(build):
			continue
		# 解锁条件检查
		if build.unlock_condition != "":
			if build.unlock_condition.begins_with("Lv"):
				var required_level := int(build.unlock_condition.substr(2))
				if player_level < required_level:
					continue
		eligible.append(build)
	return eligible

## 按权重随机选择一个 Build
func _weighted_random_pick(candidates: Array[BuildData], tag_system: TagSystem) -> BuildData:
	if candidates.is_empty():
		return null
	
	var favored_tags := tag_system.get_favored_tags()
	
	# 计算每个候选的权重
	var weights: Array[float] = []
	var total_weight: float = 0.0
	
	for build in candidates:
		var weight: float = rarity_weights.get(build.rarity, 1.0)
		
		# 规则 3：优先推荐已有流派（+50% 概率）
		if not favored_tags.is_empty():
			for tag in build.tags:
				if favored_tags.has(tag):
					weight *= BalanceData.TAG_FAVOR_BONUS
					break
		
		weights.append(weight)
		total_weight += weight
	
	# 随机选择
	var roll := randf() * total_weight
	var cumulative := 0.0
	for i in range(candidates.size()):
		cumulative += weights[i]
		if roll <= cumulative:
			return candidates[i]
	
	# 兜底返回最后一个
	return candidates[-1]

## 重置所有 Build 等级
func reset_all_build_levels() -> void:
	for build in all_builds:
		build.current_level = 0
