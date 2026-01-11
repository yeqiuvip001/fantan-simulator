#!/bin/bash
echo "📦 安装番摊模拟器所有必需依赖..."

# 1. 清理旧的 node_modules
rm -rf node_modules package-lock.json

# 2. 创建最小化 package.json
cat > package.json << 'EOF'
{
  "name": "fantan-simulator",
  "private": true,
  "version": "1.0.0",
  "type": "module",
  "homepage": "https://yourusername.github.io/fantan-simulator",
  "scripts": {
    "dev": "vite",
    "build": "vite build",
    "preview": "vite preview",
    "deploy": "npm run build && npx gh-pages -d dist"
  },
  "dependencies": {
    "react": "^18.2.0",
    "react-dom": "^18.2.0",
    "recharts": "^2.8.2",
    "framer-motion": "^10.16.4"
  },
  "devDependencies": {
    "@types/react": "^18.2.0",
    "@types/react-dom": "^18.2.0",
    "@vitejs/plugin-react": "^4.0.0",
    "typescript": "^5.0.2",
    "vite": "^4.4.5",
    "gh-pages": "^6.0.0"
  }
}
EOF

# 3. 安装所有依赖
echo "正在安装依赖，这可能需要几分钟..."
npm install

# 4. 创建必要的配置文件
echo "⚙️ 创建配置文件..."

# vite.config.ts
cat > vite.config.ts << 'EOF'
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

export default defineConfig({
  plugins: [react()],
  base: '/fantan-simulator/',
  build: {
    outDir: 'dist',
    sourcemap: false
  }
})
EOF

# tsconfig.json
cat > tsconfig.json << 'EOF'
{
  "compilerOptions": {
    "target": "ES2020",
    "useDefineForClassFields": true,
    "lib": ["ES2020", "DOM", "DOM.Iterable"],
    "module": "ESNext",
    "skipLibCheck": true,
    "moduleResolution": "bundler",
    "allowImportingTsExtensions": true,
    "resolveJsonModule": true,
    "isolatedModules": true,
    "noEmit": true,
    "jsx": "react-jsx",
    "strict": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "noFallthroughCasesInSwitch": true
  },
  "include": ["src"],
  "references": [{ "path": "./tsconfig.node.json" }]
}
EOF

# tsconfig.node.json
cat > tsconfig.node.json << 'EOF'
{
  "compilerOptions": {
    "composite": true,
    "skipLibCheck": true,
    "module": "ESNext",
    "moduleResolution": "bundler",
    "allowSyntheticDefaultImports": true,
    "strict": true
  },
  "include": ["vite.config.ts"]
}
EOF

# 5. 测试构建
echo "🔨 测试构建..."
npm run build

if [ $? -eq 0 ]; then
  echo "✅ 构建成功！"
  echo ""
  echo "🎮 项目已准备好！"
  echo "📝 可用命令："
  echo "  npm run dev      # 启动开发服务器"
  echo "  npm run build    # 构建生产版本"
  echo "  npm run deploy   # 部署到 GitHub Pages"
  echo ""
  echo "🚀 现在可以运行：npm run deploy"
else
  echo "❌ 构建失败，请检查错误信息"
fi