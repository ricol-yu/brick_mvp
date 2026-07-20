怪物精灵素材规范
================
类型: shield（护盾怪）
单帧尺寸: 80x48 像素（超出碰撞体积部分为护盾光晕装饰）
碰撞体积: 64x32

文件清单:
  idle.png          - 带护盾待机动画 spritesheet (3帧, 总尺寸 240x48)
  hit.png           - 带护盾受击动画 spritesheet (2帧, 总尺寸 160x48)
  death.png         - 死亡动画 spritesheet (6帧, 总尺寸 480x48)
  idle_broken.png   - 护盾碎裂后硬砖态待机 spritesheet (3帧, 总尺寸 240x48)
  hit_broken.png    - 护盾碎裂后硬砖态受击 spritesheet (2帧, 总尺寸 160x48)

Spritesheet 规范:
  - 格式: PNG, 32-bit RGBA, 透明背景
  - 排列: 帧水平排列, 帧间距 0px
  - 同张内帧尺寸严格一致
  - 无抗锯齿, 无 ICC 色彩配置

动画参数:
  idle:          3帧, FPS=4,  循环
  hit:           2帧, FPS=12, 播完回idle
  death:         6帧, FPS=10, 播完queue_free（前2帧护盾碎裂，后4帧砖块崩裂）
  idle_broken:   3帧, FPS=4,  循环（护盾碎裂后切换到此动画）
  hit_broken:    2帧, FPS=12, 播完回idle_broken

动画描述:
  idle:          外层护盾能量流动（光点沿边缘移动）
  hit:           护盾震动
  death:         护盾先碎裂飞散（前2帧），然后内层砖块崩裂（后4帧）
  idle_broken:   硬砖态微动（类似 hard 砖 idle）
  hit_broken:    硬砖态受击

注意:
  - 帧尺寸 80x48，比碰撞体积 64x32 大，多出部分为护盾光晕
  - broken 态素材仅绘制内层硬砖（无护盾光晕），尺寸仍为 80x48 保持一致
  - 护盾碎裂后代码会切换 sprite_frames 到 broken 态动画
