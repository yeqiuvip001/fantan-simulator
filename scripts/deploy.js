#!/usr/bin/env node

/**
 * 🚀 番摊模拟器一键部署脚本
 * 功能：自动构建并部署到 GitHub Pages
 */

const { execSync, spawn } = require('child_process');
const fs = require('fs');
const path = require('path');
const readline = require('readline');

// 颜色输出
const colors = {
  reset: '\x1b[0m',
  red: '\x1b[31m',
  green: '\x1b[32m',
  yellow: '\x1b[33m',
  blue: '\x1b[34m',
  magenta: '\x1b[35m',
  cyan: '\x1b[36m',
  white: '\x1b[37m',
  bold: '\x1b[1m'
};

// 日志函数
const log = {
  info: (msg) => console.log(`${colors.cyan}ℹ ${msg}${colors.reset}`),
  success: (msg) => console.log(`${colors.green}✓ ${msg}${colors.reset}`),
  warning: (msg) => console.log(`${colors.yellow}⚠ ${msg}${colors.reset}`),
  error: (msg) => console.log(`${colors.red}✗ ${msg}${colors.reset}`),
  step: (msg) => console.log(`${colors.magenta}→ ${msg}${colors.reset}`),
  title: (msg) => console.log(`\n${colors.bold}${colors.blue}${msg}${colors.reset}\n`)
};

// 检查命令是否存在
function checkCommand(command) {
  try {
    execSync(`command -v ${command}`, { stdio: 'ignore' });
    return true;
  } catch {
    return false;
  }
}

// 执行命令并显示输出
function executeCommand(command, options = {}) {
  const { cwd = process.cwd(), silent = false } = options;
  
  if (!silent) {
    log.step(`执行: ${command}`);
  }
  
  try {
    const output = execSync(command, { 
      cwd, 
      stdio: silent ? 'pipe' : 'inherit',
      encoding: 'utf-8'
    });
    return { success: true, output };
  } catch (error) {
    return { 
      success: false, 
      error: error.message,
      stderr: error.stderr?.toString()
    };
  }
}

// 检查配置文件
function checkConfig() {
  log.title('📋 检查配置文件');
  
  const checks = [
    {
      name: 'package.json',
      check: () => fs.existsSync('package.json'),
      fix: () => log.error('package.json 不存在，请确认在项目根目录运行')
    },
    {
      name: 'vite.config.ts',
      check: () => fs.existsSync('vite.config.ts') || fs.existsSync('vite.config.js'),
      fix: () => {
        log.warning('vite.config.ts 不存在，正在创建基础配置...');
        const config = `
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

export default defineConfig({
  plugins: [react()],
  base: '/fantan-simulator/',
})`;
        fs.writeFileSync('vite.config.ts', config);
        log.success('已创建 vite.config.ts');
      }
    },
    {
      name: 'gh-pages 依赖',
      check: () => {
        try {
          const pkg = JSON.parse(fs.readFileSync('package.json', 'utf-8'));
          return pkg.devDependencies?.['gh-pages'] || pkg.dependencies?.['gh-pages'];
        } catch {
          return false;
        }
      },
      fix: () => {
        log.warning('正在安装 gh-pages...');
        executeCommand('npm install --save-dev gh-pages');
      }
    },
    {
      name: 'package.json 脚本配置',
      check: () => {
        try {
          const pkg = JSON.parse(fs.readFileSync('package.json', 'utf-8'));
          return pkg.scripts?.deploy && pkg.scripts?.predeploy;
        } catch {
          return false;
        }
      },
      fix: () => {
        log.warning('正在更新 package.json...');
        const pkgPath = 'package.json';
        const pkg = JSON.parse(fs.readFileSync(pkgPath, 'utf-8'));
        
        if (!pkg.scripts) pkg.scripts = {};
        
        pkg.scripts.predeploy = 'npm run build';
        pkg.scripts.deploy = 'gh-pages -d dist';
        
        // 设置主页
        const username = getGitHubUsername();
        pkg.homepage = `https://${username}.github.io/fantan-simulator`;
        
        fs.writeFileSync(pkgPath, JSON.stringify(pkg, null, 2));
        log.success('已更新 package.json');
      }
    },
    {
      name: 'Git 仓库',
      check: () => fs.existsSync('.git'),
      fix: () => {
        log.warning('正在初始化 Git 仓库...');
        executeCommand('git init');
        executeCommand('git add .');
        executeCommand('git commit -m "初始提交"');
      }
    }
  ];
  
  let allPassed = true;
  
  checks.forEach(item => {
    if (item.check()) {
      log.success(`${item.name}: 通过`);
    } else {
      log.warning(`${item.name}: 不通过`);
      if (item.fix) {
        item.fix();
      } else {
        allPassed = false;
      }
    }
  });
  
  return allPassed;
}

// 获取 GitHub 用户名
function getGitHubUsername() {
  try {
    const config = execSync('git config --get remote.origin.url', { 
      encoding: 'utf-8',
      stdio: 'pipe'
    });
    
    // 从 git URL 中提取用户名
    const match = config.match(/github\.com[/:]([^/]+)/);
    if (match) return match[1];
    
    // 尝试从 git 配置获取
    const name = execSync('git config --get user.name', { 
      encoding: 'utf-8',
      stdio: 'pipe'
    }).trim();
    
    return name || 'yourusername';
  } catch {
    return 'yourusername';
  }
}

// 显示部署信息
function showDeployInfo(username) {
  log.title('🚀 部署信息');
  console.log(`
${colors.bold}项目名称:${colors.reset} 番摊模拟器
${colors.bold}部署目标:${colors.reset} GitHub Pages
${colors.bold}访问地址:${colors.reset} ${colors.green}https://${username}.github.io/fantan-simulator${colors.reset}
${colors.bold}仓库地址:${colors.reset} https://github.com/${username}/fantan-simulator
`);
}

// 交互式询问
async function askQuestion(query) {
  const rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout
  });

  return new Promise(resolve => {
    rl.question(query, answer => {
      rl.close();
      resolve(answer.trim());
    });
  });
}

// 主部署流程
async function mainDeploy() {
  log.title('🎮 番摊模拟器 GitHub Pages 一键部署');
  
  // 检查必要工具
  log.step('检查系统环境...');
  if (!checkCommand('git')) {
    log.error('Git 未安装，请先安装 Git');
    process.exit(1);
  }
  
  if (!checkCommand('node')) {
    log.error('Node.js 未安装，请先安装 Node.js');
    process.exit(1);
  }
  
  if (!checkCommand('npm')) {
    log.error('npm 未安装');
    process.exit(1);
  }
  
  log.success('环境检查通过');
  
  // 检查配置
  if (!checkConfig()) {
    log.error('配置检查失败，请手动修复上述问题');
    process.exit(1);
  }
  
  // 获取 GitHub 用户名
  const username = getGitHubUsername();
  showDeployInfo(username);
  
  // 询问是否继续
  const answer = await askQuestion(`${colors.yellow}是否开始部署？(y/N): ${colors.reset}`);
  if (answer.toLowerCase() !== 'y') {
    log.info('部署取消');
    process.exit(0);
  }
  
  // 步骤 1: 更新依赖
  log.title('📦 步骤 1: 安装依赖');
  const installResult = executeCommand('npm install', { silent: false });
  if (!installResult.success) {
    log.error('依赖安装失败');
    process.exit(1);
  }
  log.success('依赖安装完成');
  
  // 步骤 2: 构建项目
  log.title('🔨 步骤 2: 构建项目');
  const buildResult = executeCommand('npm run build', { silent: false });
  if (!buildResult.success) {
    log.error('构建失败');
    console.log(buildResult.error);
    process.exit(1);
  }
  log.success('构建完成');
  
  // 步骤 3: 检查构建文件
  log.step('验证构建文件...');
  if (!fs.existsSync('dist/index.html')) {
    log.error('构建失败：dist/index.html 不存在');
    process.exit(1);
  }
  log.success('构建文件验证通过');
  
  // 步骤 4: 部署到 GitHub Pages
  log.title('🚀 步骤 3: 部署到 GitHub Pages');
  
  // 检查是否有远程仓库
  let hasRemote = false;
  try {
    execSync('git remote get-url origin', { stdio: 'pipe' });
    hasRemote = true;
  } catch {
    hasRemote = false;
  }
  
  if (!hasRemote) {
    log.warning('未设置远程仓库，需要先设置 GitHub 仓库');
    
    const repoAnswer = await askQuestion(`${colors.yellow}是否创建新的 GitHub 仓库？(y/N): ${colors.reset}`);
    if (repoAnswer.toLowerCase() === 'y') {
      const repoName = 'fantan-simulator';
      
      // 使用 GitHub CLI 创建仓库
      if (checkCommand('gh')) {
        log.step('使用 GitHub CLI 创建仓库...');
        executeCommand(`gh repo create ${repoName} --public --push --source=. --remote=origin`);
      } else {
        log.warning('GitHub CLI 未安装，请手动创建仓库:');
        console.log(`1. 访问: ${colors.blue}https://github.com/new${colors.reset}`);
        console.log(`2. 仓库名: ${colors.green}${repoName}${colors.reset}`);
        console.log(`3. 设置为 Public`);
        console.log(`4. 不要初始化 README`);
        console.log(`\n然后运行以下命令:`);
        console.log(`${colors.cyan}git remote add origin https://github.com/${username}/${repoName}.git${colors.reset}`);
        console.log(`${colors.cyan}git push -u origin main${colors.reset}`);
        
        const pushAnswer = await askQuestion(`${colors.yellow}是否继续部署？(y/N): ${colors.reset}`);
        if (pushAnswer.toLowerCase() !== 'y') {
          process.exit(0);
        }
      }
    }
  }
  
  // 执行部署
  log.step('正在部署...');
  const deployResult = executeCommand('npm run deploy', { silent: false });
  
  if (!deployResult.success) {
    log.error('部署失败');
    console.log(deployResult.error);
    
    // 尝试手动部署
    log.warning('尝试手动部署...');
    const manualDeploy = executeCommand('npx gh-pages -d dist', { silent: false });
    
    if (!manualDeploy.success) {
      log.error('手动部署也失败了');
      process.exit(1);
    }
  }
  
  log.success('部署成功！');
  
  // 显示成功信息
  log.title('🎉 部署完成！');
  console.log(`
${colors.bold}🎮 番摊模拟器已成功部署${colors.reset}

${colors.bold}🌐 访问地址:${colors.reset} ${colors.green}https://${username}.github.io/fantan-simulator${colors.reset}

${colors.bold}📊 下一步操作:${colors.reset}
1. 等待 1-2 分钟让 GitHub Pages 生效
2. 刷新页面查看效果
3. 如需更新，只需再次运行: ${colors.cyan}npm run deploy${colors.reset}

${colors.bold}🔧 技术支持:${colors.reset}
如果遇到问题，请检查:
1. 确保仓库是 Public
2. 检查 Settings → Pages 配置
3. 查看 GitHub Actions 日志

${colors.bold}📝 作业提交格式:${colors.reset}
\`\`\`
项目名称: 番摊模拟器
在线演示: https://${username}.github.io/fantan-simulator
源代码: https://github.com/${username}/fantan-simulator
\`\`\`
`);
  
  // 自动打开浏览器（可选）
  const openAnswer = await askQuestion(`${colors.yellow}是否现在打开网站？(y/N): ${colors.reset}`);
  if (openAnswer.toLowerCase() === 'y') {
    const open = require('open');
    await open(`https://${username}.github.io/fantan-simulator`);
  }
}

// 错误处理
process.on('uncaughtException', (error) => {
  log.error(`未捕获错误: ${error.message}`);
  console.error(error.stack);
  process.exit(1);
});

// 运行主函数
if (require.main === module) {
  mainDeploy().catch(error => {
    log.error(`部署失败: ${error.message}`);
    console.error(error);
    process.exit(1);
  });
}

module.exports = { mainDeploy };