## 场景切换管理（Autoload）
## 负责在主场景间切换（主菜单 → 游戏世界 → 商店等）
extends Node

## 场景路径常量
const SCENE_MAIN_MENU := "res://scenes/ui/main_menu.tscn"
const SCENE_GAME_WORLD := "res://scenes/main/game_world.tscn"
const SCENE_META_SHOP := "res://scenes/main/meta_shop.tscn"
const SCENE_GAME_OVER := "res://scenes/ui/game_over.tscn"

## 当前场景节点引用
var current_scene: Node = null

## 待传递到下一场景的数据
var pending_data: Dictionary = {}

func _ready() -> void:
	# 等一帧让主场景加载完
	await get_tree().process_frame
	current_scene = get_tree().current_scene

## 切换到指定场景
func change_scene(scene_path: String) -> void:
	if current_scene:
		current_scene.queue_free()
		current_scene = null
	
	var packed_scene := load(scene_path) as PackedScene
	if packed_scene:
		var new_scene: Node = packed_scene.instantiate()
		get_tree().root.call_deferred("add_child", new_scene)
		get_tree().set_deferred("current_scene", new_scene)
		current_scene = new_scene
	else:
		push_error("场景加载失败: " + scene_path)

## 跳转到主菜单
func goto_main_menu() -> void:
	change_scene(SCENE_MAIN_MENU)
	GameManager.change_state(GameManager.GameState.MAIN_MENU)

## 跳转到游戏世界
func goto_game_world() -> void:
	change_scene(SCENE_GAME_WORLD)
	EventBus.game_started.emit()

## 跳转到永久升级商店
func goto_meta_shop() -> void:
	change_scene(SCENE_META_SHOP)
	GameManager.change_state(GameManager.GameState.META_SHOP)

## 跳转到游戏结束画面
func goto_game_over(cleared: bool, stats: Dictionary) -> void:
	pending_data = {"cleared": cleared, "stats": stats}
	change_scene(SCENE_GAME_OVER)
	# 延迟一帧后传递数据（等场景加载完成）
	await get_tree().process_frame
	if current_scene and current_scene.has_method("_on_game_over"):
		current_scene._on_game_over(cleared, stats)
	pending_data.clear()
