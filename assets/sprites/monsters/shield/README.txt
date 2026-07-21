怪物精灵素材规范
================
类型: shield（护盾怪）
单帧尺寸: 120x72 像素（超出碰撞体积部分为护盾光晕装饰）
碰撞体积: 96x48

文件清单:
  idle.png          - 带护盾待机动画 spritesheet (3帧, 总尺寸 364x72)
  hit.png           - 带护盾受击动画 spritesheet (2帧, 总尺寸 242x72)
  death.png         - 死亡动画 spritesheet (6帧, 总尺寸 730x72)
  idle_broken.png   - 护盾碎裂后硬砖态待机 spritesheet (3帧, 总尺寸 364x72)
  hit_broken.png    - 护盾碎裂后硬砖态受击 spritesheet (2帧, 总尺寸 242x72)

Spritesheet 规范:
  - 格式: PNG, 32-bit RGBA, 透明背景
  - 排列: 帧水平排列, 帧间距 2px（相邻帧之间留2像素空白，防止边缘粘连）
  - 同张内帧尺寸严格一致
  - 无抗锯齿, 无 ICC 色彩配置

动画参数:
  idle:          3帧, FPS=4,  循环
  hit:           2帧, FPS=12, 播完回idle
  death:         6帧, FPS=10, 播完queue_free（前2帧护盾碎裂，后4帧砖块崩裂）
  idle_broken:   3帧, FPS=4,  循环（护盾碎裂后切换到此动画）
  hit_broken:    2帧, FPS=12, 播完回idle_broken

动画描述:
  idle:          铁灰色矮壮骑士，举着圆形蓝色能量盾，盾面有光点流动。护盾边缘光点沿圆周移动，骑士身体微晃
  hit:           护盾受击震动，光点剧烈闪烁
  death:         前2帧护盾碎裂飞散，后4帧骑士本体崩裂
  idle_broken:   失去护盾的骑士，armor 有裂纹，微微喘息
  hit_broken:    无盾骑士受击，armor 裂纹扩大

注意:
  - 帧尺寸 120x72，比碰撞体积 96x48 大，多出部分为护盾光晕
  - broken 态素材仅绘制内层硬砖（无护盾光晕），尺寸仍为 120x72 保持一致
  - 护盾碎裂后代码会切换 sprite_frames 到 broken 态动画
