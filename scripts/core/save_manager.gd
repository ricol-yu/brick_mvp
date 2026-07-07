## 存档管理（Autoload）
## 管理永久升级进度、金币、统计数据的持久化
extends Node

## 存档文件路径
const SAVE_PATH := "user://save_data.json"

## 存档数据结构
var save_data: Dictionary = {
	"coins": 0,                      ## 金币总量
	"meta_upgrades": {},              ## 永久升级等级 { "upgrade_id": level }
	"total_runs": 0,                  ## 总游戏局数
	"total_bricks_destroyed": 0,      ## 累计击碎砖块数
	"total_bosses_defeated": 0,       ## 累计击败 Boss 数
	"best_level_reached": 1,          ## 最高等级记录
	"best_run_duration": 0.0,         ## 最长存活时间
	"settings": {
		"bgm_volume": 0.8,
		"sfx_volume": 0.8,
		"fullscreen": false,
	},
}

## 是否已加载存档
var is_loaded: bool = false

func _ready() -> void:
	load_data()
	EventBus.coins_changed.connect(_on_coins_changed)
	EventBus.meta_upgrade_purchased.connect(_on_meta_upgrade_purchased)
	EventBus.game_over.connect(_on_game_over)

## 获取金币数量
func get_coins() -> int:
	return save_data["coins"]

## 增加金币
func add_coins(amount: int) -> void:
	save_data["coins"] += amount
	EventBus.coins_changed.emit(save_data["coins"])
	save_data_to_disk()

## 消耗金币
func spend_coins(amount: int) -> bool:
	if save_data["coins"] >= amount:
		save_data["coins"] -= amount
		EventBus.coins_changed.emit(save_data["coins"])
		save_data_to_disk()
		return true
	return false

## 获取永久升级等级
func get_meta_upgrade_level(upgrade_id: String) -> int:
	if save_data["meta_upgrades"].has(upgrade_id):
		return save_data["meta_upgrades"][upgrade_id]
	return 0

## 设置永久升级等级
func set_meta_upgrade_level(upgrade_id: String, level: int) -> void:
	save_data["meta_upgrades"][upgrade_id] = level
	save_data_to_disk()

## 获取设置
func get_setting(key: String, default_value: Variant = null) -> Variant:
	if save_data["settings"].has(key):
		return save_data["settings"][key]
	return default_value

## 更新设置
func set_setting(key: String, value: Variant) -> void:
	save_data["settings"][key] = value
	save_data_to_disk()

## 从磁盘加载存档
func load_data() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		is_loaded = true
		return
	
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file:
		var json_text := file.get_as_text()
		var json := JSON.new()
		var err := json.parse(json_text)
		if err == OK:
			var loaded := json.data as Dictionary
			if loaded:
				_merge_save_data(loaded)
		else:
			push_warning("存档解析失败，使用默认数据")
		file.close()
	
	is_loaded = true

## 保存存档到磁盘
func save_data_to_disk() -> void:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(save_data, "  "))
		file.close()
	else:
		push_error("存档保存失败")

## 重置存档（慎用）
func reset_save() -> void:
	save_data = {
		"coins": 0,
		"meta_upgrades": {},
		"total_runs": 0,
		"total_bricks_destroyed": 0,
		"total_bosses_defeated": 0,
		"best_level_reached": 1,
		"best_run_duration": 0.0,
		"settings": {
			"bgm_volume": 0.8,
			"sfx_volume": 0.8,
			"fullscreen": false,
		},
	}
	save_data_to_disk()

## 合并加载的数据（只覆盖已存在的键）
func _merge_save_data(loaded: Dictionary) -> void:
	for key in loaded:
		if save_data.has(key):
			if save_data[key] is Dictionary and loaded[key] is Dictionary:
				for sub_key in loaded[key]:
					save_data[key][sub_key] = loaded[key][sub_key]
			else:
				save_data[key] = loaded[key]

func _on_coins_changed(_new_amount: int) -> void:
	pass  # 已自动保存

func _on_meta_upgrade_purchased(upgrade_id: String) -> void:
	var current_level := get_meta_upgrade_level(upgrade_id)
	set_meta_upgrade_level(upgrade_id, current_level + 1)

func _on_game_over(_cleared: bool, stats: Dictionary) -> void:
	save_data["total_runs"] += 1
	save_data["total_bricks_destroyed"] += stats.get("bricks_destroyed", 0)
	save_data["total_bosses_defeated"] += stats.get("bosses_defeated", 0)
	
	var max_level: int = stats.get("max_level_reached", 1)
	if max_level > save_data["best_level_reached"]:
		save_data["best_level_reached"] = max_level
	
	var duration: float = stats.get("run_duration", 0.0)
	if duration > save_data["best_run_duration"]:
		save_data["best_run_duration"] = duration
	
	save_data_to_disk()
