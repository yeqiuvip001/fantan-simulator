#!/bin/bash
# 🚀 番摊模拟器 - 环境设置脚本
# 功能：创建完整的项目结构，安装所有依赖

set -e  # 遇到错误时退出

echo "🎮 番摊模拟器 - 环境初始化"
echo "=========================="

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 日志函数
log_info() { echo -e "${BLUE}ℹ $1${NC}"; }
log_success() { echo -e "${GREEN}✓ $1${NC}"; }
log_warning() { echo -e "${YELLOW}⚠ $1${NC}"; }
log_error() { echo -e "${RED}✗ $1${NC}"; }

# 检查命令是否存在
check_command() {
    command -v "$1" >/dev/null 2>&1
}

# 执行命令
execute() {
    echo -e "${BLUE}→ 执行: $1${NC}"
    if eval "$1"; then
        return 0
    else
        log_error "命令失败: $1"
        return 1
    fi
}

# 获取 GitHub 用户名
get_github_username() {
    local username=""
    
    # 尝试从 git 配置获取
    if check_command git; then
        username=$(git config --get user.name 2>/dev/null || echo "")
    fi
    
    # 如果获取不到，提示用户输入
    if [ -z "$username" ] || [ "$username" = "yourusername" ]; then
        read -p "请输入你的 GitHub 用户名: " username
    fi
    
    echo "$username"
}

# 主函数
main() {
    log_info "1. 检查系统环境..."
    
    # 检查必要工具
    if ! check_command node; then
        log_error "Node.js 未安装，请先安装 Node.js (>=16.0.0)"
        exit 1
    fi
    
    if ! check_command npm; then
        log_error "npm 未安装"
        exit 1
    fi
    
    if ! check_command git; then
        log_warning "Git 未安装，部分功能可能受限"
    fi
    
    log_success "环境检查通过"
    log_info "Node.js 版本: $(node --version)"
    log_info "npm 版本: $(npm --version)"
    
    # 获取 GitHub 用户名
    log_info "2. 配置项目信息..."
    GITHUB_USERNAME=$(get_github_username)
    log_info "GitHub 用户名: $GITHUB_USERNAME"
    
    # 清理旧的项目文件（保留用户代码）
    log_info "3. 清理旧构建..."
    execute "rm -rf dist node_modules/.vite"
    
    # 创建目录结构
    log_info "4. 创建项目结构..."
    mkdir -p src/components src/hooks src/utils src/types public scripts docs .github/workflows
    
    # 创建 package.json
    log_info "5. 创建 package.json..."
    cat > package.json << EOF
{
  "name": "fantan-simulator",
  "private": true,
  "version": "1.0.0",
  "type": "module",
  "homepage": "https://${GITHUB_USERNAME}.github.io/fantan-simulator",
  "scripts": {
    "dev": "vite",
    "build": "vite build",
    "preview": "vite preview",
    "predeploy": "npm run build",
    "deploy": "gh-pages -d dist",
    "setup": "bash scripts/setup.sh",
    "deploy:full": "bash scripts/deploy.sh",
    "verify": "bash scripts/verify.sh"
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
    "@types/node": "^20.10.0",
    "@vitejs/plugin-react": "^4.0.0",
    "typescript": "^5.0.2",
    "vite": "^4.5.0",
    "gh-pages": "^6.0.0"
  }
}
EOF
    
    # 创建 vite.config.ts
    log_info "6. 创建 Vite 配置..."
    cat > vite.config.ts << 'EOF'
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

export default defineConfig({
  plugins: [react()],
  base: '/fantan-simulator/',
  
  server: {
    port: 5173,
    host: true,
    open: false
  },
  
  build: {
    outDir: 'dist',
    emptyOutDir: true,
    sourcemap: false,
    rollupOptions: {
      output: {
        assetFileNames: 'assets/[name]-[hash][extname]',
        chunkFileNames: 'assets/[name]-[hash].js',
        entryFileNames: 'assets/[name]-[hash].js'
      }
    }
  }
})
EOF
    
    # 创建 TypeScript 配置
    log_info "7. 创建 TypeScript 配置..."
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
    
    cat > tsconfig.node.json << 'EOF'
{
  "compilerOptions": {
    "composite": true,
    "skipLibCheck": true,
    "module": "ESNext",
    "moduleResolution": "bundler",
    "allowSyntheticDefaultImports": true
  },
  "include": ["vite.config.ts"]
}
EOF
    
    # 创建 index.html
    log_info "8. 创建 HTML 入口文件..."
    cat > index.html << EOF
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
        font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
      }
      #root {
        min-height: 100vh;
      }
      .loading {
        position: fixed;
        top: 0; left: 0; right: 0; bottom: 0;
        display: flex;
        flex-direction: column;
        align-items: center;
        justify-content: center;
        background: linear-gradient(135deg, #1a2a3a 0%, #0d1824 100%);
        z-index: 9999;
        transition: opacity 0.5s;
      }
      .loading.hidden {
        opacity: 0;
        pointer-events: none;
      }
      .spinner {
        width: 50px;
        height: 50px;
        border: 4px solid rgba(255, 255, 255, 0.1);
        border-radius: 50%;
        border-top-color: #d4af37;
        animation: spin 1s linear infinite;
        margin-bottom: 20px;
      }
      @keyframes spin {
        to { transform: rotate(360deg); }
      }
    </style>
  </head>
  <body>
    <div class="loading" id="loading">
      <div class="spinner"></div>
      <h2>加载番摊模拟器...</h2>
      <p>广东传统游戏概率模拟系统</p>
    </div>
    <div id="root"></div>
    <script>
      window.addEventListener('load', function() {
        setTimeout(function() {
          const loading = document.getElementById('loading');
          if (loading) {
            loading.classList.add('hidden');
            setTimeout(() => loading.style.display = 'none', 500);
          }
        }, 800);
      });
    </script>
    <script type="module" src="./src/main.tsx"></script>
  </body>
</html>
EOF
    
    # 创建源代码文件（如果不存在）
    log_info "9. 创建源代码文件..."
    
    if [ ! -f "src/main.tsx" ]; then
        cat > src/main.tsx << 'EOF'
import React from 'react'
import ReactDOM from 'react-dom/client'
import App from './App'
import './index.css'

console.log('🎮 番摊模拟器启动中...')

const rootElement = document.getElementById('root')
if (!rootElement) {
    console.error('错误: 找不到 #root 元素')
    document.body.innerHTML = '<div style="padding: 50px; text-align: center; color: white; background: #1a2a3a;"><h1>错误: 找不到根元素</h1><p>请检查 index.html 文件</p></div>'
} else {
    ReactDOM.createRoot(rootElement).render(
        <React.StrictMode>
            <App />
        </React.StrictMode>
    )
}
EOF
    fi
    
    if [ ! -f "src/App.tsx" ]; then
        cat > src/App.tsx << 'EOF'
import React, { useState } from 'react'

function App() {
  const [balance, setBalance] = useState(1000)
  const [selectedNumber, setSelectedNumber] = useState<number | null>(null)
  const [result, setResult] = useState<number | null>(null)
  const [history, setHistory] = useState<Array<{number: number, result: number, win: boolean}>>([])

  const handleBet = (number: number) => {
    if (balance < 10) {
      alert('余额不足！')
      return
    }
    
    setSelectedNumber(number)
    setBalance(prev => prev - 10)
    
    // 模拟开摊
    setTimeout(() => {
      const randomResult = Math.floor(Math.random() * 4) + 1
      setResult(randomResult)
      
      const win = number === randomResult
      if (win) {
        setBalance(prev => prev + 30) // 1赔3
      }
      
      setHistory(prev => [...prev.slice(-9), { number, result: randomResult, win }])
      setSelectedNumber(null)
      
      setTimeout(() => setResult(null), 2000)
    }, 1500)
  }

  return (
    <div style={{
      minHeight: '100vh',
      background: 'linear-gradient(135deg, #1a2a3a 0%, #0d1824 100%)',
      color: 'white',
      padding: '20px',
      fontFamily: 'Arial, sans-serif'
    }}>
      <header style={{ textAlign: 'center', marginBottom: '30px' }}>
        <h1 style={{ color: '#d4af37', fontSize: '2.5rem', marginBottom: '10px' }}>
          🎮 番摊模拟器
        </h1>
        <p style={{ opacity: 0.8 }}>广东传统游戏概率模拟系统</p>
      </header>

      <div style={{ 
        maxWidth: '800px', 
        margin: '0 auto',
        background: 'rgba(0, 0, 0, 0.3)',
        borderRadius: '15px',
        padding: '25px',
        border: '2px solid #d4af37'
      }}>
        <div style={{ 
          textAlign: 'center', 
          marginBottom: '30px',
          padding: '15px',
          background: 'rgba(212, 175, 55, 0.1)',
          borderRadius: '10px'
        }}>
          <h2 style={{ margin: 0 }}>💰 当前余额: <span style={{ color: '#4CAF50' }}>¥{balance}</span></h2>
          <p style={{ margin: '10px 0 0', opacity: 0.7 }}>每次下注: ¥10 (猜中赢¥30)</p>
        </div>

        <div style={{ marginBottom: '30px' }}>
          <h3 style={{ textAlign: 'center', marginBottom: '20px' }}>🎯 选择数字下注</h3>
          <div style={{
            display: 'grid',
            gridTemplateColumns: 'repeat(2, 1fr)',
            gap: '15px',
            maxWidth: '400px',
            margin: '0 auto'
          }}>
            {[1, 2, 3, 4].map(num => (
              <button
                key={num}
                onClick={() => handleBet(num)}
                disabled={selectedNumber !== null}
                style={{
                  aspectRatio: '1',
                  fontSize: '3rem',
                  fontWeight: 'bold',
                  background: selectedNumber === num 
                    ? '#4CAF50' 
                    : result === num 
                      ? '#2196F3' 
                      : 'rgba(212, 175, 55, 0.2)',
                  border: `3px solid ${
                    selectedNumber === num 
                      ? '#45a049' 
                      : result === num 
                        ? '#1976D2' 
                        : '#d4af37'
                  }`,
                  borderRadius: '10px',
                  color: 'white',
                  cursor: selectedNumber === null ? 'pointer' : 'not-allowed',
                  transition: 'all 0.3s'
                }}
              >
                {num}
              </button>
            ))}
          </div>
          
          {result && (
            <div style={{
              textAlign: 'center',
              marginTop: '20px',
              padding: '15px',
              background: 'rgba(33, 150, 243, 0.2)',
              borderRadius: '10px',
              animation: 'pulse 1s infinite'
            }}>
              <h3 style={{ margin: 0 }}>
                🎲 开摊结果: <span style={{ fontSize: '2em' }}>{result}</span>
              </h3>
            </div>
          )}
        </div>

        {history.length > 0 && (
          <div style={{ marginTop: '30px' }}>
            <h3 style={{ textAlign: 'center', marginBottom: '15px' }}>📊 最近记录</h3>
            <div style={{
              display: 'grid',
              gridTemplateColumns: 'repeat(auto-fill, minmax(150px, 1fr))',
              gap: '10px'
            }}>
              {history.map((item, index) => (
                <div key={index} style={{
                  padding: '10px',
                  background: item.win 
                    ? 'rgba(76, 175, 80, 0.2)' 
                    : 'rgba(244, 67, 54, 0.2)',
                  border: `1px solid ${item.win ? '#4CAF50' : '#F44336'}`,
                  borderRadius: '8px',
                  textAlign: 'center'
                }}>
                  <div>下注: {item.number}</div>
                  <div>开摊: {item.result}</div>
                  <div style={{ fontWeight: 'bold', color: item.win ? '#4CAF50' : '#F44336' }}>
                    {item.win ? '✅ 赢' : '❌ 输'}
                  </div>
                </div>
              ))}
            </div>
          </div>
        )}

        <div style={{ 
          marginTop: '30px', 
          padding: '20px', 
          background: 'rgba(255, 255, 255, 0.05)',
          borderRadius: '10px'
        }}>
          <h3 style={{ color: '#d4af37' }}>📖 游戏规则</h3>
          <ul style={{ lineHeight: '1.6' }}>
            <li>点击数字 1-4 进行下注（每次¥10）</li>
            <li>系统随机开摊（1-4 随机数）</li>
            <li>猜中数字赢得 3 倍下注金额（¥30）</li>
            <li>每个数字出现概率理论为 25%</li>
            <li>庄家长期优势约为 25%</li>
          </ul>
        </div>
      </div>

      <footer style={{
        textAlign: 'center',
        marginTop: '40px',
        paddingTop: '20px',
        borderTop: '1px solid rgba(255, 255, 255, 0.1)',
        opacity: 0.7,
        fontSize: '0.9rem'
      }}>
        <p>🎓 计算机编程课程项目 - 番摊模拟器</p>
        <p>📊 本程序用于概率统计与可视化研究，请勿用于真实赌博</p>
        <p>🌐 部署于 GitHub Pages | {new Date().getFullYear()}</p>
      </footer>

      <style>{`
        @keyframes pulse {
          0%, 100% { opacity: 1; }
          50% { opacity: 0.7; }
        }
        
        button:hover:not(:disabled) {
          transform: scale(1.05);
          box-shadow: 0 0 15px rgba(212, 175, 55, 0.5);
        }
        
        button:active:not(:disabled) {
          transform: scale(0.98);
        }
      `}</style>
    </div>
  )
}

export default App
EOF
    fi
    
    if [ ! -f "src/index.css" ]; then
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

button {
  font-family: inherit;
  border: none;
  outline: none;
}

#root {
  min-height: 100vh;
}
EOF
    fi
    
    # 创建静态资源
    log_info "10. 创建静态资源..."
    
    if [ ! -f "public/vite.svg" ]; then
        mkdir -p public
        cat > public/vite.svg << 'EOF'
<svg xmlns="http://www.w3.org/2000/svg" width="32" height="32" viewBox="0 0 32 32">
  <path fill="#646cff" d="M29.883 6.146L17.622 28.896a1.038 1.038 0 0 1-1.794.107l-2.903-4.511l14.796-18.297a.428.428 0 0 0-.465-.682l-6.325 2.241l-4.576-7.373a.857.857 0 0 1 1.2-1.2l16 9.714a.857.857 0 0 1-.097 1.525l-11.834 4.35l9.143 14.222c.25.388.657.609 1.093.609c.014 0 .027 0 .041-.001a1.429 1.429 0 0 0 1.12-.837l12-26a.857.857 0 0 0-1.238-1.077z"/>
  <path fill="#646cff" d="M20.273 2.99L4.32 19.437a.857.857 0 0 0 .628 1.454h10.457l-5.536 8.3a1.038 1.038 0 0 1-1.794-.107L2.117 6.146a.857.857 0 0 1 1.238-1.077l16 9.714a.857.857 0 0 0 1.2-1.2z" opacity=".45"/>
</svg>
EOF
    fi
    
    # 创建 .nojekyll 文件
    log_info "11. 创建 GitHub Pages 配置文件..."
    echo "" > .nojekyll
    
    # 安装依赖
    log_info "12. 安装项目依赖..."
    execute "npm install"
    
    # 创建部署脚本
    log_info "13. 创建部署脚本..."
    cat > scripts/deploy.sh << 'EOF'
#!/bin/bash
# 🚀 番摊模拟器 - 一键部署脚本

set -e

cd "$(dirname "$0")/.."

# 颜色
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log() { echo -e "${BLUE}→${NC} $1"; }
success() { echo -e "${GREEN}✓${NC} $1"; }
warn() { echo -e "${YELLOW}⚠${NC} $1"; }
error() { echo -e "${RED}✗${NC} $1"; }

echo "🎮 番摊模拟器 - 一键部署"
echo "========================"

# 检查环境
log "检查环境..."
if ! command -v node >/dev/null 2>&1; then
    error "Node.js 未安装"
    exit 1
fi

if ! command -v npm >/dev/null 2>&1; then
    error "npm 未安装"
    exit 1
fi

# 检查 GitHub 配置
if [ ! -f "package.json" ]; then
    error "package.json 不存在，请先运行: npm run setup"
    exit 1
fi

# 获取 GitHub 用户名
USERNAME=$(node -e "try { console.log(require('./package.json').homepage.match(/https:\/\/([^\.]+)\.github\.io/)[1]) } catch(e) { console.log('') }")
if [ -z "$USERNAME" ]; then
    read -p "请输入 GitHub 用户名: " USERNAME
    node -e "
        const fs = require('fs');
        const pkg = JSON.parse(fs.readFileSync('package.json'));
        pkg.homepage = 'https://$USERNAME.github.io/fantan-simulator';
        fs.writeFileSync('package.json', JSON.stringify(pkg, null, 2));
    "
    success "已更新 GitHub 用户名: $USERNAME"
fi

# 构建项目
log "构建项目..."
if ! npm run build; then
    error "构建失败"
    exit 1
fi
success "构建成功"

# 添加 .nojekyll 文件
log "配置 GitHub Pages..."
touch dist/.nojekyll

# 检查 Git 仓库
if ! command -v git >/dev/null 2>&1; then
    warn "Git 未安装，跳过仓库检查"
else
    if [ ! -d ".git" ]; then
        log "初始化 Git 仓库..."
        git init
        git add .
        git commit -m "初始提交: 番摊模拟器"
    fi
    
    if ! git remote get-url origin >/dev/null 2>&1; then
        warn "未设置远程仓库"
        read -p "是否创建 GitHub 仓库？(y/N): " CREATE_REPO
        if [[ $CREATE_REPO =~ ^[Yy]$ ]]; then
            if command -v gh >/dev/null 2>&1; then
                gh repo create fantan-simulator --public --push --source=. --remote=origin
                success "GitHub 仓库已创建"
            else
                echo "请手动创建 GitHub 仓库:"
                echo "1. 访问 https://github.com/new"
                echo "2. 仓库名: fantan-simulator"
                echo "3. 设置为 Public"
                echo ""
                echo "然后运行:"
                echo "git remote add origin https://github.com/$USERNAME/fantan-simulator.git"
                echo "git push -u origin main"
                read -p "按 Enter 继续..."
            fi
        fi
    fi
fi

# 部署到 GitHub Pages
log "部署到 GitHub Pages..."
if npx gh-pages -d dist; then
    success "部署成功！"
    echo ""
    echo "🎉 番摊模拟器已上线！"
    echo ""
    echo "🌐 访问地址:"
    echo "  https://$USERNAME.github.io/fantan-simulator"
    echo ""
    echo "📁 源码仓库:"
    echo "  https://github.com/$USERNAME/fantan-simulator"
    echo ""
    echo "🔄 更新网站:"
    echo "  npm run deploy:full"
    echo ""
    echo "📝 作业提交信息:"
    echo "  项目名称: 番摊模拟器"
    echo "  在线演示: https://$USERNAME.github.io/fantan-simulator"
    echo "  源代码: https://github.com/$USERNAME/fantan-simulator"
else
    error "部署失败"
    echo "尝试手动部署: npx gh-pages -d dist --repo https://github.com/$USERNAME/fantan-simulator.git"
    exit 1
fi
EOF
    
    # 创建验证脚本
    cat > scripts/verify.sh << 'EOF'
#!/bin/bash
# 🔍 番摊模拟器 - 验证脚本

cd "$(dirname "$0")/.."

echo "🔍 番摊模拟器 - 系统验证"
echo "======================="

# 检查文件
echo "📁 文件检查:"
files=("index.html" "package.json" "vite.config.ts" "src/main.tsx" "src/App.tsx")
all_ok=true

for file in "${files[@]}"; do
    if [ -f "$file" ]; then
        echo "  ✅ $file"
    else
        echo "  ❌ $file (缺失)"
        all_ok=false
    fi
done

# 检查依赖
echo ""
echo "📦 依赖检查:"
if npm list vite >/dev/null 2>&1; then
    echo "  ✅ Vite 已安装"
else
    echo "  ❌ Vite 未安装"
    all_ok=false
fi

if npm list react >/dev/null 2>&1; then
    echo "  ✅ React 已安装"
else
    echo "  ❌ React 未安装"
    all_ok=false
fi

if npm list gh-pages >/dev/null 2>&1; then
    echo "  ✅ gh-pages 已安装"
else
    echo "  ❌ gh-pages 未安装"
    all_ok=false
fi

# 测试构建
echo ""
echo "🔨 构建测试:"
if npm run build 2>&1 | grep -q "error"; then
    echo "  ❌ 构建失败"
    npm run build 2>&1 | grep -A5 -B5 "error"
    all_ok=false
else
    echo "  ✅ 构建成功"
    
    # 检查 dist 内容
    if [ -d "dist" ]; then
        echo "  📁 dist 文件夹内容:"
        ls -la dist/ | grep -E "\.(html|js|css|json)$" | while read line; do
            echo "    $line"
        done
    fi
fi

# GitHub 配置
echo ""
echo "🌐 GitHub 配置:"
if [ -f "package.json" ]; then
    HOMEPAGE=$(node -e "try { console.log(require('./package.json').homepage) } catch(e) { console.log('未设置') }")
    echo "  Homepage: $HOMEPAGE"
    
    if [[ $HOMEPAGE == *"github.io"* ]]; then
        echo "  ✅ GitHub Pages 配置正确"
    else
        echo "  ⚠️  Homepage 可能需要更新"
    fi
fi

# 总结
echo ""
echo "📊 验证结果:"
if $all_ok; then
    echo "  ✅ 所有检查通过！可以部署项目。"
    echo ""
    echo "🚀 运行以下命令部署:"
    echo "  npm run deploy:full"
else
    echo "  ⚠️  发现一些问题，请修复后重试。"
    echo ""
    echo "🔧 运行以下命令修复:"
    echo "  npm run setup"
fi
EOF
    
    # 创建 GitHub Actions 配置
    log_info "14. 创建 GitHub Actions 自动部署..."
    mkdir -p .github/workflows
    cat > .github/workflows/deploy.yml << 'EOF'
name: Deploy to GitHub Pages

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]
  workflow_dispatch:  # 手动触发

jobs:
  build-and-deploy:
    runs-on: ubuntu-latest
    
    steps:
    - name: Checkout
      uses: actions/checkout@v3
      
    - name: Setup Node.js
      uses: actions/setup-node@v3
      with:
        node-version: '18'
        cache: 'npm'
        
    - name: Install dependencies
      run: npm ci
      
    - name: Build
      run: npm run build
      
    - name: Add .nojekyll
      run: touch dist/.nojekyll
      
    - name: Deploy to GitHub Pages
      uses: peaceiris/actions-gh-pages@v3
      with:
        github_token: ${{ secrets.GITHUB_TOKEN }}
        publish_dir: ./dist
        user_name: github-actions[bot]
        user_email: github-actions[bot]@users.noreply.github.com
        commit_message: "Deploy: ${{ github.event.head_commit.message || '自动部署' }}"
EOF
    
    # 创建 README
    log_info "15. 创建 README..."
    cat > README.md << EOF
# 🎮 番摊模拟器

广东传统游戏概率模拟与可视化系统

## 🌐 在线演示
[https://$GITHUB_USERNAME.github.io/fantan-simulator](https://$GITHUB_USERNAME.github.io/fantan-simulator)

## 📁 项目简介
番摊模拟器是一个基于 React + TypeScript 的Web应用，模拟广东传统番摊游戏，展示概率统计与数据可视化。

## 🚀 快速开始

### 环境设置
\`\`\`bash
# 安装所有依赖并初始化项目
npm run setup
\`\`\`

### 本地开发
\`\`\`bash
# 启动开发服务器
npm run dev

# 访问 http://localhost:5173/fantan-simulator
\`\`\`

### 一键部署
\`\`\`bash
# 构建并部署到 GitHub Pages
npm run deploy:full
\`\`\`

### 验证配置
\`\`\`bash
# 检查项目配置
npm run verify
\`\`\`

## 📊 功能特性
- 完整的番摊游戏模拟
- 实时概率统计
- 游戏历史记录
- 响应式设计
- 庄家优势可视化

## 🛠 技术栈
- React 18 + TypeScript
- Vite 构建工具
- GitHub Pages 部署
- Recharts 数据可视化

## 📁 项目结构
\`\`\`
fantan-simulator/
├── src/                    # 源代码
├── scripts/               # 部署脚本
├── public/                # 静态资源
├── docs/                  # 文档
└── .github/workflows/     # CI/CD
\`\`\`

## 🔧 部署脚本
项目包含完整的自动化脚本：

1. \`scripts/setup.sh\` - 环境初始化
2. \`scripts/deploy.sh\` - 一键部署
3. \`scripts/verify.sh\` - 系统验证

## 📝 作业提交
**项目信息：**
- 名称：番摊模拟器
- 在线演示：https://$GITHUB_USERNAME.github.io/fantan-simulator
- 源代码：https://github.com/$GITHUB_USERNAME/fantan-simulator

## 📄 许可证
本项目仅用于学术研究，请勿用于真实赌博。

---
*计算机编程课程项目 - 番摊模拟器*
EOF
    
    # 设置脚本权限
    execute "chmod +x scripts/*.sh"
    
    # 创建 docs
    cat > docs/DEPLOYMENT.md << 'EOF'
# 部署文档

## 部署步骤

### 1. 首次部署
```bash
# 1. 环境设置
npm run setup

# 2. 一键部署
npm run deploy:full

# 3. 验证部署
npm run verify