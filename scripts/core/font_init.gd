## 字体初始化 Autoload（后备方案）
## 主配置已在 project.godot [gui] theme/default_font 中设置
## 此脚本确保在所有环境下字体都能正确加载
extends Node

## 使用 preload 确保编译时嵌入，Web 导出更可靠
var _font: FontFile = preload("res://assets/fonts/SourceHanSansSC-Regular.otf")

func _ready() -> void:
	call_deferred("_apply_chinese_font")

func _apply_chinese_font() -> void:
	if _font == null:
		push_error("[FontInit] 中文字体加载失败")
		return

	var t := Theme.new()
	t.default_font = _font

	# 同时设置 Window 和根 Viewport，确保所有环境生效
	get_window().theme = t
	get_tree().root.theme = t
	print("[FontInit] 中文字体已全局应用: SourceHanSansSC-Regular.otf")
