## 字体初始化 Autoload
## 主配置已在 project.godot [gui] theme/default_font 中设置
## 此脚本解决 WebGL 字体纹理图集首次渲染时机问题
extends Node

## 使用 preload 确保编译时嵌入，Web 导出更可靠
var _font: FontFile = preload("res://assets/fonts/NotoSansSC-Regular.ttf")

func _ready() -> void:
	# 立即同步应用主题（不延迟、不 await），确保在主场景加载前完成
	_apply_chinese_font()

func _apply_chinese_font() -> void:
	if _font == null:
		push_error("[FontInit] 中文字体加载失败")
		return

	# 设置全局主题（同步，不等帧）
	var t := Theme.new()
	t.default_font = _font
	get_window().theme = t
	get_tree().root.theme = t
	print("[FontInit] 中文字体已全局应用: NotoSansSC-Regular.ttf")
