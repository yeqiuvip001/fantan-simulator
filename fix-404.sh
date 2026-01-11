#!/bin/bash
cd /workspaces/fantan-simulator

echo "🔧 修复 GitHub Pages 404 问题..."

# 1. 清理并重新构建
echo "1. 重新构建项目..."
rm -rf dist
npm run build

# 2. 添加 .nojekyll 文件（防止 Jekyll 处理）
echo "2. 添加 .nojekyll 文件..."
touch dist/.nojekyll

# 3. 修复 index.html 中的 base 路径
echo "3. 修复 HTML 中的路径..."
sed -i 's|href="/|href="./|g' dist/index.html
sed -i 's|src="/|src="./|g' dist/index.html

# 4. 创建 404.html 页面
echo "4. 创建 404.html 重定向..."
cat > dist/404.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <title>重定向到番摊模拟器</title>
    <script>
        // 尝试多种重定向方式
        const paths = [
            '/fantan-simulator/',
            '/fantan-simulator/index.html',
            './index.html',
            'index.html'
        ];
        
        let redirected = false;
        for (const path of paths) {
            try {
                const link = document.createElement('a');
                link.href = path;
                if (link.pathname) {
                    window.location.href = path;
                    redirected = true;
                    break;
                }
            } catch (e) {
                continue;
            }
        }
        
        if (!redirected) {
            document.body.innerHTML = `
                <div style="text-align: center; padding: 50px; font-family: Arial;">
                    <h1>🎮 番摊模拟器</h1>
                    <p>页面重定向失败，请手动访问：</p>
                    <p><a href="./index.html">./index.html</a></p>
                    <p><a href="/fantan-simulator/index.html">/fantan-simulator/index.html</a></p>
                </div>
            `;
        }
    </script>
    <noscript>
        <meta http-equiv="refresh" content="0;url=./index.html">
    </noscript>
</head>
<body>
    <p>正在重定向到番摊模拟器...</p>
</body>
</html>
EOF

# 5. 检查 package.json 中的 homepage
echo "5. 检查 homepage 配置..."
if grep -q '"homepage"' package.json; then
    HOMEPAGE=$(node -e "console.log(require('./package.json').homepage)")
    echo "当前 homepage: $HOMEPAGE"
    
    # 提取用户名
    USERNAME=$(echo "$HOMEPAGE" | sed -n 's|https://\([^.]*\)\.github\.io.*|\1|p')
    if [ -z "$USERNAME" ]; then
        echo "请输入你的 GitHub 用户名:"
        read USERNAME
        node -e "
            const fs = require('fs');
            const pkg = JSON.parse(fs.readFileSync('package.json'));
            pkg.homepage = 'https://$USERNAME.github.io/fantan-simulator';
            fs.writeFileSync('package.json', JSON.stringify(pkg, null, 2));
        "
        echo "已更新 homepage: https://$USERNAME.github.io/fantan-simulator"
    fi
else
    echo "❌ package.json 中没有 homepage 字段"
    echo "请输入你的 GitHub 用户名:"
    read USERNAME
    node -e "
        const fs = require('fs');
        const pkg = JSON.parse(fs.readFileSync('package.json'));
        pkg.homepage = 'https://$USERNAME.github.io/fantan-simulator';
        fs.writeFileSync('package.json', JSON.stringify(pkg, null, 2));
    "
fi

# 6. 更新 vite.config.ts 确保 base 正确
echo "6. 更新 Vite 配置..."
cat > vite.config.ts << 'EOF'
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

export default defineConfig({
  plugins: [react()],
  // GitHub Pages 需要正确的 base
  base: '/fantan-simulator/',
  
  build: {
    outDir: 'dist',
    emptyOutDir: true,
    // 确保正确处理资源路径
    assetsDir: 'assets',
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

# 7. 重新构建
echo "7. 重新构建..."
rm -rf dist
npm run build

# 8. 添加 CNAME 文件（可选）
echo "8. 创建 CNAME 文件..."
USERNAME=$(node -e "try { console.log(require('./package.json').homepage.match(/https:\/\/([^\.]+)\.github\.io/)[1]) } catch(e) { console.log('') }")
if [ -n "$USERNAME" ]; then
    echo "$USERNAME.github.io/fantan-simulator" > dist/CNAME
fi

# 9. 验证 dist 内容
echo ""
echo "=== 验证构建结果 ==="
echo "dist 文件夹结构:"
find dist -type f | sort

echo ""
echo "✅ 修复完成！现在重新部署"