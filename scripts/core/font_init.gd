## 字体初始化 Autoload
## 通过代码创建全局 Theme，确保 Web 导出时中文正常显示
## 不依赖 .tres 文件，避免 Web 上资源加载失败
extends Node

func _ready() -> void:
	call_deferred("_apply_chinese_font")

func _apply_chinese_font() -> void:
	var font := load("res://assets/fonts/simhei.ttf")
	if font == null:
		push_error("[FontInit] 中文字体加载失败: res://assets/fonts/simhei.ttf")
		return

	# 用代码创建 Theme（比 .tres 文件更可靠）
	var t := Theme.new()
	t.default_font = font

	# 设置到主窗口的全局 Theme 上
	# get_window() 返回主 Window，其 theme 会级联到所有子 Control 节点
	get_window().theme = t
	print("[FontInit] 中文字体已全局应用: simhei.ttf")
