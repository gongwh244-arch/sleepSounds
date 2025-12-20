#!/bin/bash

# Firebase 数据导入脚本
# 用于批量导入声音数据到 Firestore

echo "🔥 Firebase 数据导入脚本"
echo "========================"
echo ""

# 检查 Firebase CLI 是否已安装
if ! command -v firebase &> /dev/null
then
    echo "❌ Firebase CLI 未安装"
    echo "正在安装 Firebase CLI..."
    npm install -g firebase-tools
    if [ $? -ne 0 ]; then
        echo "❌ 安装失败,请手动运行: npm install -g firebase-tools"
        exit 1
    fi
    echo "✅ Firebase CLI 安装成功"
fi

echo "✅ Firebase CLI 已安装"
echo ""

# 检查是否已登录
echo "📝 检查登录状态..."
firebase projects:list &> /dev/null
if [ $? -ne 0 ]; then
    echo "需要登录 Firebase..."
    firebase login
    if [ $? -ne 0 ]; then
        echo "❌ 登录失败"
        exit 1
    fi
fi

echo "✅ 已登录 Firebase"
echo ""

# 设置项目
PROJECT_ID="sleep-sounds-a26ee"
echo "🎯 设置项目: $PROJECT_ID"
firebase use $PROJECT_ID

if [ $? -ne 0 ]; then
    echo "❌ 项目设置失败,请确认项目 ID 是否正确"
    exit 1
fi

echo "✅ 项目设置成功"
echo ""

# 检查数据文件是否存在
if [ ! -f "firestore-data.json" ]; then
    echo "❌ 找不到 firestore-data.json 文件"
    echo "请确保该文件在当前目录下"
    exit 1
fi

echo "📦 找到数据文件: firestore-data.json"
echo ""

# 导入数据
echo "🚀 开始导入数据到 Firestore..."
echo "⚠️  注意: 这将会添加数据到您的 Firestore 数据库"
echo ""
read -p "确认继续? (y/n) " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    echo "❌ 取消导入"
    exit 1
fi

# 使用 Node.js 脚本导入数据
node << 'EOF'
const admin = require('firebase-admin');
const fs = require('fs');

// 初始化 Firebase Admin
const serviceAccount = require('./serviceAccountKey.json');
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();
const data = JSON.parse(fs.readFileSync('firestore-data.json', 'utf8'));

async function importData() {
  const batch = db.batch();
  let count = 0;

  for (const [docId, docData] of Object.entries(data.sounds)) {
    const docRef = db.collection('sounds').doc(docId);
    batch.set(docRef, docData);
    count++;
  }

  await batch.commit();
  console.log(`✅ 成功导入 ${count} 条数据`);
  process.exit(0);
}

importData().catch(error => {
  console.error('❌ 导入失败:', error);
  process.exit(1);
});
EOF

echo ""
echo "🎉 导入完成!"
echo "现在可以重新运行应用查看数据了"
