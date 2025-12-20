//
//  UIDeviceExtension.swift
//  ZYBScanSearch
//
//  Created by Vision on 2024/2/19.
//  Copyright © 2024 zuoyebang. All rights reserved.
//

import Foundation
import UIKit

@objc extension UIDevice {
    static let type = UIDevice.current.userInterfaceIdiom
    
    static let isIphoneX = UIScreen.main.bounds.size.height == 812 || UIScreen.main.bounds.size.height == 896
    
    @available(iOS 13.0, *)
    static func kd_currentWindowScene() -> UIWindowScene? {
        guard let connectedScenes = UIApplication.shared.connectedScenes as? Set<UIWindowScene> else { return nil }
        if let foregroundActive = connectedScenes.first(where: { windowScene in windowScene.activationState == .foregroundActive }) {//有foregroundActive
            return foregroundActive
        } else {//无foregroundActive
            return connectedScenes.first
        }
    }
    
    static func kd_currentWindow() -> UIWindow? {
        var windows : [UIWindow]
        if #available(iOS 13.0, *) {
            if let currentWindowScene = kd_currentWindowScene() {
                windows = currentWindowScene.windows
            } else {
                return nil
            }
        } else {
            windows = UIApplication.shared.windows
        }
        if windows.isEmpty {
            return nil
        } else {
            if let keyWindow = windows.first(where: { window in window.isKeyWindow }) {//有keyWindow
                return keyWindow
            } else {//无keyWindow
                return windows.first
            }
        }
    }
    
    static func kd_statusBarX() -> CGFloat {
        var statusBarHeight: CGFloat = 0
        if #available(iOS 13.0, *) {
            if let currentWindowScene = kd_currentWindowScene() {
                guard let statusBarManager = currentWindowScene.statusBarManager else { return 0 }
                statusBarHeight = statusBarManager.statusBarFrame.origin.x
            } else {
                return 0
            }
        } else {
            statusBarHeight = UIApplication.shared.statusBarFrame.origin.x
        }
        return statusBarHeight
    }
    
    static func kd_statusBarHeight() -> CGFloat {
        var statusBarHeight: CGFloat = 0
        if #available(iOS 13.0, *) {
            if let currentWindowScene = kd_currentWindowScene() {
                guard let statusBarManager = currentWindowScene.statusBarManager else { return 0 }
                statusBarHeight = statusBarManager.statusBarFrame.size.height
            } else {
                return 0
            }
        } else {
            statusBarHeight = UIApplication.shared.statusBarFrame.size.height
        }
        return statusBarHeight
    }
    
    static func kd_safeAreaTop() -> CGFloat {
        if #available(iOS 12, *) {
            guard let window = kd_currentWindow() else { return 0 }
            return window.safeAreaInsets.top
        } else {
            return UIApplication.shared.statusBarFrame.size.height
        }
    }
    
    static func kd_navigationBarHeight() -> CGFloat {
        if type == .pad  {
            return 50
        } else {
            return 44
        }
    }
    
    static func kd_navigationFullHeight() -> CGFloat {
        return kd_safeAreaTop() + kd_navigationBarHeight()
    }
    
    static func kd_tabBarHeight() -> CGFloat {
        if type == .pad  {
            return 50
        } else {
            return 49
        }
    }
    
    static func kd_safeAreaBottom() -> CGFloat {
        if #available(iOS 12, *) {
            guard let window = kd_currentWindow() else { return 0 }
            return window.safeAreaInsets.bottom
        } else {
            return 0
        }
    }
    
    static func kd_tabBarFullHeight() -> CGFloat {
        if type == .pad  {
            if kd_safeAreaBottom() > 0 {
                return kd_tabBarHeight() + kd_safeAreaBottom() - 5
            } else {
                return kd_tabBarHeight() + kd_safeAreaBottom()
            }
        } else {
            return kd_tabBarHeight() + kd_safeAreaBottom()
        }
    }
}
