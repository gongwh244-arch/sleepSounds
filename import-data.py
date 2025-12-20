#!/usr/bin/env python3
"""
Firebase Firestore 数据导入脚本 (Python 版本)

使用方法:
1. 安装依赖: pip3 install firebase-admin
2. 运行: python3 import-data.py
"""

import firebase_admin
from firebase_admin import credentials, firestore
import sys

# 初始化 Firebase Admin SDK
try:
    # 尝试使用服务账号密钥文件
    import os
    service_account_path = 'serviceAccountKey.json'
    
    if os.path.exists(service_account_path):
        print("🔑 使用服务账号密钥文件认证...")
        cred = credentials.Certificate(service_account_path)
        firebase_admin.initialize_app(cred)
    else:
        print("⚠️  未找到 serviceAccountKey.json 文件")
        print("尝试使用应用默认凭据...")
        firebase_admin.initialize_app(options={
            'projectId': 'sleep-sounds-a26ee'
        })
    
    db = firestore.client()
    print("✅ 成功连接到 Firebase\n")
except Exception as e:
    print(f"❌ Firebase 初始化失败: {e}")
    print("\n解决方案:")
    print("1. 下载服务账号密钥文件:")
    print("   - 访问 https://console.firebase.google.com/")
    print("   - 选择项目 → 设置 → 服务账号")
    print("   - 点击 '生成新的私钥'")
    print("   - 保存为 serviceAccountKey.json")
    print("   - 放到当前目录: /Users/zyb/Documents/sleep/SleepSounds/")
    print("\n2. 或者使用 Google Cloud 认证:")
    print("   gcloud auth application-default login")
    sys.exit(1)

# 定义要导入的数据
sounds_data = [
    # 睡眠分类
    {
        "name": "雨声",
        "iconName": "cloud.rain.fill",
        "category": "sleep",
        "isLocked": False,
        "mp3Url": "https://drive.google.com/file/d/1N0Vji-sCO69yJ92XyZ5tNSYaJNX_QSKX/view?usp=drive_link"
    },
    {
        "name": "海浪",
        "iconName": "water.waves",
        "category": "sleep",
        "isLocked": False,
        "mp3Url": "https://drive.google.com/file/d/1N0Vji-sCO69yJ92XyZ5tNSYaJNX_QSKX/view?usp=drive_link"
    },
    {
        "name": "森林",
        "iconName": "leaf.fill",
        "category": "sleep",
        "isLocked": True,
        "mp3Url": "https://drive.google.com/file/d/1N0Vji-sCO69yJ92XyZ5tNSYaJNX_QSKX/view?usp=drive_link"
    },
    {
        "name": "雷声",
        "iconName": "cloud.bolt.rain.fill",
        "category": "sleep",
        "isLocked": True,
        "mp3Url": "https://drive.google.com/file/d/1N0Vji-sCO69yJ92XyZ5tNSYaJNX_QSKX/view?usp=drive_link"
    },
    {
        "name": "篝火",
        "iconName": "flame.fill",
        "category": "sleep",
        "isLocked": False,
        "mp3Url": "https://drive.google.com/file/d/1N0Vji-sCO69yJ92XyZ5tNSYaJNX_QSKX/view?usp=drive_link"
    },
    {
        "name": "风声",
        "iconName": "wind",
        "category": "sleep",
        "isLocked": True,
        "mp3Url": "https://drive.google.com/file/d/1N0Vji-sCO69yJ92XyZ5tNSYaJNX_QSKX/view?usp=drive_link"
    },
    {
        "name": "溪流",
        "iconName": "drop.fill",
        "category": "sleep",
        "isLocked": False,
        "mp3Url": "https://drive.google.com/file/d/1N0Vji-sCO69yJ92XyZ5tNSYaJNX_QSKX/view?usp=drive_link"
    },
    {
        "name": "夜晚",
        "iconName": "moon.stars.fill",
        "category": "sleep",
        "isLocked": True,
        "mp3Url": "https://drive.google.com/file/d/1N0Vji-sCO69yJ92XyZ5tNSYaJNX_QSKX/view?usp=drive_link"
    },
    
    # 宝宝分类 - 嘘声哄睡
    {
        "name": "嘘声1",
        "iconName": "speaker.wave.2.fill",
        "category": "baby",
        "subCategory": "shush",
        "isLocked": False,
        "mp3Url": "https://drive.google.com/file/d/1N0Vji-sCO69yJ92XyZ5tNSYaJNX_QSKX/view?usp=drive_link"
    },
    {
        "name": "嘘声2",
        "iconName": "speaker.wave.3.fill",
        "category": "baby",
        "subCategory": "shush",
        "isLocked": True,
        "mp3Url": "https://drive.google.com/file/d/1N0Vji-sCO69yJ92XyZ5tNSYaJNX_QSKX/view?usp=drive_link"
    },
    {
        "name": "嘘声3",
        "iconName": "speaker.wave.1.fill",
        "category": "baby",
        "subCategory": "shush",
        "isLocked": False,
        "mp3Url": "https://drive.google.com/file/d/1N0Vji-sCO69yJ92XyZ5tNSYaJNX_QSKX/view?usp=drive_link"
    },
    
    # 宝宝分类 - 白噪音
    {
        "name": "吹风机",
        "iconName": "fan.fill",
        "category": "baby",
        "subCategory": "white_noise",
        "isLocked": False,
        "mp3Url": "https://drive.google.com/file/d/1N0Vji-sCO69yJ92XyZ5tNSYaJNX_QSKX/view?usp=drive_link"
    },
    {
        "name": "吸尘器",
        "iconName": "circle.fill",
        "category": "baby",
        "subCategory": "white_noise",
        "isLocked": True,
        "mp3Url": "https://drive.google.com/file/d/1N0Vji-sCO69yJ92XyZ5tNSYaJNX_QSKX/view?usp=drive_link"
    },
    {
        "name": "洗衣机",
        "iconName": "washer.fill",
        "category": "baby",
        "subCategory": "white_noise",
        "isLocked": False,
        "mp3Url": "https://drive.google.com/file/d/1N0Vji-sCO69yJ92XyZ5tNSYaJNX_QSKX/view?usp=drive_link"
    },
    {
        "name": "汽车",
        "iconName": "car.fill",
        "category": "baby",
        "subCategory": "white_noise",
        "isLocked": True,
        "mp3Url": "https://drive.google.com/file/d/1N0Vji-sCO69yJ92XyZ5tNSYaJNX_QSKX/view?usp=drive_link"
    },
    
    # 宝宝分类 - 自然声音
    {
        "name": "小溪",
        "iconName": "drop.fill",
        "category": "baby",
        "subCategory": "nature",
        "isLocked": False,
        "mp3Url": "https://drive.google.com/file/d/1N0Vji-sCO69yJ92XyZ5tNSYaJNX_QSKX/view?usp=drive_link"
    },
    {
        "name": "鸟鸣",
        "iconName": "bird.fill",
        "category": "baby",
        "subCategory": "nature",
        "isLocked": True,
        "mp3Url": "https://drive.google.com/file/d/1N0Vji-sCO69yJ92XyZ5tNSYaJNX_QSKX/view?usp=drive_link"
    },
    {
        "name": "雨声",
        "iconName": "cloud.rain.fill",
        "category": "baby",
        "subCategory": "nature",
        "isLocked": False,
        "mp3Url": "https://drive.google.com/file/d/1N0Vji-sCO69yJ92XyZ5tNSYaJNX_QSKX/view?usp=drive_link"
    }
]

def import_data():
    """导入数据到 Firestore"""
    print("🚀 开始导入数据到 Firestore...\n")
    
    try:
        # 使用批量写入
        batch = db.batch()
        sounds_ref = db.collection('sounds')
        
        for sound in sounds_data:
            doc_ref = sounds_ref.document()
            batch.set(doc_ref, sound)
            print(f"✓ 准备导入: {sound['name']} ({sound['category']})")
        
        # 提交批量写入
        batch.commit()
        
        print(f"\n✅ 成功导入 {len(sounds_data)} 条数据!")
        print("🎉 现在可以重新运行应用查看数据了\n")
        
        # 显示统计信息
        sleep_count = sum(1 for s in sounds_data if s['category'] == 'sleep')
        baby_count = sum(1 for s in sounds_data if s['category'] == 'baby')
        print(f"📊 数据统计:")
        print(f"   - 睡眠分类: {sleep_count} 个")
        print(f"   - 宝宝分类: {baby_count} 个")
        print(f"   - 总计: {len(sounds_data)} 个\n")
        
    except Exception as e:
        print(f"❌ 导入失败: {e}")
        sys.exit(1)

if __name__ == "__main__":
    import_data()
