怪物精灵素材规范
================
类型: haste（加速怪）
单帧尺寸: 64x32 像素
碰撞体积: 64x32

文件清单:
  idle.png   - 待机动画 spritesheet (3帧, 总尺寸 192x32)
  hit.png    - 受击动画 spritesheet (2帧, 总尺寸 128x32)
  death.png  - 死亡动画 spritesheet (4帧, 总尺寸 256x32)

Spritesheet 规范:
  - 格式: PNG, 32-bit RGBA, 透明背景
  - 排列: 帧水平排列, 帧间距 0px
  - 同张内帧尺寸严格一致
  - 无抗锯齿, 无 ICC 色彩配置

动画参数:
  idle:  3帧, FPS=6,  循环
  hit:   2帧, FPS=14, 播完回idle
  death: 4帧, FPS=12, 播完queue_free

动画描述:
  idle:  速度线从尾部快速闪过
  hit:   加速残影
  death: 爆裂 + 速度波纹向外扩散
