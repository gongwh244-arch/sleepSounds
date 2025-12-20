/**
 * Firebase Firestore 数据导入脚本 (简化版)
 * 
 * 使用方法:
 * 1. 安装依赖: npm install firebase-admin
 * 2. 下载服务账号密钥 (见下方说明)
 * 3. 运行: node import-data-simple.js
 */

const admin = require('firebase-admin');
const fs = require('fs');

// ============================================
// 配置部分
// ============================================

// 方法 1: 使用服务账号密钥文件 (推荐)
// 从 Firebase Console 下载 serviceAccountKey.json
// const serviceAccount = require('./serviceAccountKey.json');
// admin.initializeApp({
//   credential: admin.credential.cert(serviceAccount)
// });

// 方法 2: 使用项目 ID (需要先运行 firebase login)
admin.initializeApp({
    projectId: 'sleep-sounds-a26ee'
});

const db = admin.firestore();

// ============================================
// 数据定义
// ============================================

const soundsData = [
    // 睡眠分类
    {
        name: "雨声",
        iconName: "cloud.rain.fill",
        category: "sleep",
        isLocked: false
    },
    {
        name: "海浪",
        iconName: "water.waves",
        category: "sleep",
        isLocked: false
    },
    {
        name: "森林",
        iconName: "leaf.fill",
        category: "sleep",
        isLocked: true
    },
    {
        name: "雷声",
        iconName: "cloud.bolt.rain.fill",
        category: "sleep",
        isLocked: true
    },
    {
        name: "篝火",
        iconName: "flame.fill",
        category: "sleep",
        isLocked: false
    },
    {
        name: "风声",
        iconName: "wind",
        category: "sleep",
        isLocked: true
    },
    {
        name: "溪流",
        iconName: "drop.fill",
        category: "sleep",
        isLocked: false
    },
    {
        name: "夜晚",
        iconName: "moon.stars.fill",
        category: "sleep",
        isLocked: true
    },

    // 宝宝分类 - 嘘声哄睡
    {
        name: "嘘声1",
        iconName: "speaker.wave.2.fill",
        category: "baby",
        subCategory: "shush",
        isLocked: false
    },
    {
        name: "嘘声2",
        iconName: "speaker.wave.3.fill",
        category: "baby",
        subCategory: "shush",
        isLocked: true
    },
    {
        name: "嘘声3",
        iconName: "speaker.wave.1.fill",
        category: "baby",
        subCategory: "shush",
        isLocked: false
    },

    // 宝宝分类 - 白噪音
    {
        name: "吹风机",
        iconName: "fan.fill",
        category: "baby",
        subCategory: "white_noise",
        isLocked: false
    },
    {
        name: "吸尘器",
        iconName: "circle.fill",
        category: "baby",
        subCategory: "white_noise",
        isLocked: true
    },
    {
        name: "洗衣机",
        iconName: "washer.fill",
        category: "baby",
        subCategory: "white_noise",
        isLocked: false
    },
    {
        name: "汽车",
        iconName: "car.fill",
        category: "baby",
        subCategory: "white_noise",
        isLocked: true
    },

    // 宝宝分类 - 自然声音
    {
        name: "小溪",
        iconName: "drop.fill",
        category: "baby",
        subCategory: "nature",
        isLocked: false
    },
    {
        name: "鸟鸣",
        iconName: "bird.fill",
        category: "baby",
        subCategory: "nature",
        isLocked: true
    },
    {
        name: "雨声",
        iconName: "cloud.rain.fill",
        category: "baby",
        subCategory: "nature",
        isLocked: false
    }
];

// ============================================
// 导入函数
// ============================================

async function importData() {
    console.log('🚀 开始导入数据到 Firestore...\n');

    try {
        // 使用批量写入提高效率
        const batch = db.batch();

        soundsData.forEach((sound, index) => {
            const docRef = db.collection('sounds').doc();
            batch.set(docRef, sound);
            console.log(`✓ 准备导入: ${sound.name} (${sound.category})`);
        });

        // 提交批量写入
        await batch.commit();

        console.log(`\n✅ 成功导入 ${soundsData.length} 条数据!`);
        console.log('🎉 现在可以重新运行应用查看数据了\n');

        process.exit(0);
    } catch (error) {
        console.error('❌ 导入失败:', error);
        process.exit(1);
    }
}

// ============================================
// 执行导入
// ============================================

importData();
