怪物精灵素材规范
================
类型: split（分裂怪）
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
  idle:  3帧, FPS=5,  循环
  hit:   2帧, FPS=12, 播完回idle
  death: 4帧, FPS=10, 播完queue_free

动画描述:
  idle:  细胞状脉动，中心微微膨胀收缩
  hit:   收缩震颤
  death: 从中间裂开，两半向左右分离（暗示即将一分为二）
