//
//  BitMaskType.swift
//  Flappy Bird
//
//  Created by i-Techsys.com on 16/12/12.
//  Copyright © 2016年 i-Techsys. All rights reserved.
//

import UIKit

struct 物理层 {
    static let 无: UInt32 =        0
    static let 游戏角色: UInt32 = 0b1  // 1
    static let 障碍物: UInt32  = 0b10  // 2
    static let 地面: UInt32   = 0b100  // 4
}

enum 图层: CGFloat {
    case 背景
    case 障碍物
    case 前景
    case 游戏角色
    case UI
}

enum 游戏状态 {
    case 主菜单
    case 教程
    case 游戏
    case 跌落
    case 显示分数
    case 结束🔚
}
