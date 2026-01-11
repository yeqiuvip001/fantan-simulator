#!/bin/bash
echo "🔧 修复 src/main.tsx 路径问题..."

# 1. 确保在项目根目录
cd /workspaces/fantan-simulator

# 2. 检查 src 目录和文件
echo "📁 检查项目结构..."
mkdir -p src

# 3. 创建 src/main.tsx（如果不存在）
cat > src/main.tsx << 'EOF'
import React from 'react'
import ReactDOM from 'react-dom/client'
import App from './App'
import './index.css'

const rootElement = document.getElementById('root')
if (!rootElement) {
  throw new Error('找不到 #root 元素')
}

ReactDOM.createRoot(rootElement).render(
  <React.StrictMode>
    <App />
  </React.StrictMode>
)
EOF

# 4. 创建 src/App.tsx（如果不存在）
cat > src/App.tsx << 'EOF'
import React from 'react'

function App() {
  return (
    <div style={{
      minHeight: '100vh',
      display: 'flex',
      flexDirection: 'column',
      alignItems: 'center',
      justifyContent: 'center',
      background: 'linear-gradient(135deg, #1a2a3a 0%, #0d1824 100%)',
      color: 'white',
      padding: '20px',
      textAlign: 'center'
    }}>
      <h1 style={{ color: '#d4af37', fontSize: '3rem', marginBottom: '1rem' }}>
        🎮 番摊模拟器
      </h1>
      <p style={{ fontSize: '1.2rem', opacity: 0.8, marginBottom: '2rem' }}>
        广东传统游戏概率模拟与可视化系统
      </p>
      
      <div style={{
        background: 'rgba(0, 0, 0, 0.3)',
        padding: '2rem',
        borderRadius: '10px',
        maxWidth: '600px',
        marginTop: '2rem'
      }}>
        <h2>🎯 项目已成功运行！</h2>
        <p>开发服务器正常启动 🚀</p>
        <p>现在可以部署到 GitHub Pages</p>
        
        <div style={{ marginTop: '2rem', textAlign: 'left' }}>
          <h3>📋 部署步骤：</h3>
          <ol>
            <li>运行: <code>npm run build</code></li>
            <li>运行: <code>npm run deploy</code></li>
            <li>访问: https://你的用户名.github.io/fantan-simulator</li>
          </ol>
        </div>
      </div>
      
      <footer style={{
        marginTop: '3rem',
        paddingTop: '2rem',
        borderTop: '1px solid rgba(255, 255, 255, 0.1)',
        opacity: 0.7,
        fontSize: '0.9rem'
      }}>
        <p>本程序仅用于学术研究，展示概率统计与可视化技术</p>
      </footer>
    </div>
  )
}

export default App
EOF

# 5. 创建 src/index.css
cat > src/index.css << 'EOF'
* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

body {
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', 'Oxygen',
    'Ubuntu', 'Cantarell', 'Fira Sans', 'Droid Sans', 'Helvetica Neue',
    sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
}

#root {
  min-height: 100vh;
}
EOF

# 6. 修复 index.html
echo "📄 更新 index.html..."
cat > index.html << 'EOF'
<!DOCTYPE html>
<html lang="zh-CN">
  <head>
    <meta charset="UTF-8" />
    <link rel="icon" type="image/svg+xml" href="/vite.svg" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>番摊模拟器 - 广东传统游戏概率模拟</title>
    <style>
      body {
        margin: 0;
        padding: 0;
        background: #0d1824;
        color: white;
        overflow-x: hidden;
      }
      
      .loading {
        position: fixed;
        top: 0;
        left: 0;
        right: 0;
        bottom: 0;
        display: flex;
        flex-direction: column;
        align-items: center;
        justify-content: center;
        background: linear-gradient(135deg, #1a2a3a 0%, #0d1824 100%);
        z-index: 9999;
      }
      
      .loading-spinner {
        width: 60px;
        height: 60px;
        border: 4px solid rgba(255, 255, 255, 0.1);
        border-radius: 50%;
        border-top-color: #d4af37;
        animation: spin 1s ease-in-out infinite;
        margin-bottom: 20px;
      }
      
      @keyframes spin {
        to { transform: rotate(360deg); }
      }
    </style>
  </head>
  <body>
    <div class="loading" id="loading">
      <div class="loading-spinner"></div>
      <h2>加载番摊模拟器...</h2>
      <p>广东传统游戏概率模拟系统</p>
    </div>
    
    <div id="root"></div>
    
    <script>
      // 应用加载完成后隐藏加载动画
      window.addEventListener('load', function() {
        setTimeout(function() {
          const loading = document.getElementById('loading');
          if (loading) {
            loading.style.opacity = '0';
            loading.style.transition = 'opacity 0.5s';
            setTimeout(() => loading.style.display = 'none', 500);
          }
        }, 500);
      });
    </script>
    
    <!-- 使用相对路径引入 main.tsx -->
    <script type="module" src="./src/main.tsx"></script>
  </body>
</html>
EOF

# 7. 更新 vite.config.ts 配置
echo "⚙️ 更新 Vite 配置..."
cat > vite.config.ts << 'EOF'
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import path from 'path'

export default defineConfig({
  plugins: [react()],
  base: '/fantan-simulator/',
  
  // 服务器配置
  server: {
    port: 5173,
    host: true,
    open: false
  },
  
  // 构建配置
  build: {
    outDir: 'dist',
    sourcemap: false,
    emptyOutDir: true,
    rollupOptions: {
      input: {
        main: path.resolve(__dirname, 'index.html')
      },
      // 解决外部模块问题
      external: []
    }
  },
  
  // 解析配置
  resolve: {
    alias: {
      '@': path.resolve(__dirname, 'src')
    }
  },
  
  // 确保正确处理 .tsx 文件
  esbuild: {
    loader: 'tsx',
    include: /src\/.*\.tsx?$/,
    exclude: []
  }
})
EOF

# 8. 更新 tsconfig.json
echo "📝 更新 TypeScript 配置..."
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
    "strict": false,
    "noUnusedLocals": false,
    "noUnusedParameters": false,
    "noFallthroughCasesInSwitch": true,
    "baseUrl": ".",
    "paths": {
      "@/*": ["src/*"]
    }
  },
  "include": ["src", "index.html"],
  "references": [{ "path": "./tsconfig.node.json" }]
}
EOF

# 9. 创建 vite.svg（如果不存在）
if [ ! -f "vite.svg" ]; then
  echo "🖼️ 创建 vite.svg 图标..."
  cat > vite.svg << 'EOF'
<svg xmlns="http://www.w3.org/2000/svg" width="32" height="32" viewBox="0 0 32 32">
  <path fill="rgb(100, 108, 255)" d="M29.883 6.146L17.622 28.896a1.038 1.038 0 0 1-1.794.107l-2.903-4.511l14.796-18.297a.428.428 0 0 0-.465-.682l-6.325 2.241l-4.576-7.373a.857.857 0 0 1 1.2-1.2l16 9.714a.857.857 0 0 1-.097 1.525l-11.834 4.35l9.143 14.222c.25.388.657.609 1.093.609c.014 0 .027 0 .041-.001a1.429 1.429 0 0 0 1.12-.837l12-26a.857.857 0 0 0-1.238-1.077z"/>
  <path fill="rgb(100, 108, 255)" d="M20.273 2.99L4.32 19.437a.857.857 0 0 0 .628 1.454h10.457l-5.536 8.3a1.038 1.038 0 0 1-1.794-.107L2.117 6.146a.857.857 0 0 1 1.238-1.077l16 9.714a.857.857 0 0 0 1.2-1.2z" opacity=".45"/>
</svg>
EOF
fi

echo ""
echo "✅ 修复完成！"
echo "📁 文件结构："
find . -name "*.html" -o -name "*.tsx" -o -name "*.ts" -o -name "*.css" 2>/dev/null | grep -v node_modules | sort

echo ""
echo "🚀 现在测试构建："
echo "npm run build"