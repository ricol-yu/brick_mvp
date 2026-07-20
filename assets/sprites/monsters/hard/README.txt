怪物精灵素材规范
================
类型: hard（硬砖怪）
单帧尺寸: 64x32 像素
碰撞体积: 64x32

文件清单:
  idle.png   - 待机动画 spritesheet (2帧, 总尺寸 128x32)
  hit.png    - 受击动画 spritesheet (3帧, 总尺寸 192x32)
  death.png  - 死亡动画 spritesheet (5帧, 总尺寸 320x32)

Spritesheet 规范:
  - 格式: PNG, 32-bit RGBA, 透明背景
  - 排列: 帧水平排列, 帧间距 0px
  - 同张内帧尺寸严格一致
  - 无抗锯齿, 无 ICC 色彩配置

动画参数:
  idle:  2帧, FPS=3,  循环
  hit:   3帧, FPS=14, 播完回idle
  death: 5帧, FPS=8,  播完queue_free

动画描述:
  idle:  岩石纹理微微明暗交替
  hit:   裂纹闪烁
  death: 岩石崩裂，较大碎块
