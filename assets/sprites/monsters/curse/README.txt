怪物精灵素材规范
================
类型: curse（诅咒怪）
单帧尺寸: 64x32 像素
碰撞体积: 64x32

文件清单:
  idle.png   - 待机动画 spritesheet (3帧, 总尺寸 192x32)
  hit.png    - 受击动画 spritesheet (2帧, 总尺寸 128x32)
  death.png  - 死亡动画 spritesheet (5帧, 总尺寸 320x32)

Spritesheet 规范:
  - 格式: PNG, 32-bit RGBA, 透明背景
  - 排列: 帧水平排列, 帧间距 0px
  - 同张内帧尺寸严格一致
  - 无抗锯齿, 无 ICC 色彩配置

动画参数:
  idle:  3帧, FPS=4,  循环
  hit:   2帧, FPS=12, 播完回idle
  death: 5帧, FPS=8,  播完queue_free

动画描述:
  idle:  暗紫色能量缓慢脉动
  hit:   诅咒符文闪烁
  death: 诅咒爆炸，紫色烟雾残留

注意:
  - death 动画最后几帧应暗示"释放诅咒"（代码在 death 动画结束后触发诅咒效果）
  - 色调以暗紫色为主，与 normal 砖形成对比
