怪物精灵素材规范
================
类型: regen（再生怪）
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
  idle:  3帧, FPS=4,  循环
  hit:   2帧, FPS=12, 播完回idle
  death: 4帧, FPS=10, 播完queue_free

动画描述:
  idle:  绿色光晕从中心向外扩散
  hit:   回缩 + 绿光闪烁
  death: 绿色融化，向下滴落消散

注意:
  - 回血时代码会修改 modulate，素材颜色保持明亮绿色基调
  - 代码会触发再生粒子效果，idle 动画与粒子叠加
