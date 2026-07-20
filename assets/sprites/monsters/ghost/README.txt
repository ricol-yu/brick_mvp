怪物精灵素材规范
================
类型: ghost（幽灵怪）
单帧尺寸: 64x32 像素
碰撞体积: 64x32

文件清单:
  idle.png   - 待机动画 spritesheet (4帧, 总尺寸 256x32)
  hit.png    - 受击动画 spritesheet (2帧, 总尺寸 128x32)
  death.png  - 死亡动画 spritesheet (5帧, 总尺寸 320x32)

Spritesheet 规范:
  - 格式: PNG, 32-bit RGBA, 透明背景
  - 排列: 帧水平排列, 帧间距 0px
  - 同张内帧尺寸严格一致
  - 无抗锯齿, 无 ICC 色彩配置

动画参数:
  idle:  4帧, FPS=3,  循环
  hit:   2帧, FPS=10, 播完回idle
  death: 5帧, FPS=8,  播完queue_free

动画描述:
  idle:  整体透明度缓慢波动（帧间 alpha: 1.0 -> 0.6 -> 1.0）
  hit:   灵体闪烁更剧烈
  death: 幽灵向上飘散，逐渐透明

注意:
  - 实体态 idle 帧间透明度变化：帧1 alpha=1.0, 帧2=0.8, 帧3=0.6, 帧4=0.8
  - 灵体态由代码通过 modulate.a=0.3 控制，素材按正常不透明绘制即可
  - 不要在素材中硬编码灵体透明度，由代码动态控制
