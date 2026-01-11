import React from 'react'
import ReactDOM from 'react-dom/client'
import App from './App.tsx'
import './index.css'

console.log('🚀 番摊模拟器正在加载...')

const rootElement = document.getElementById('root')
if (!rootElement) {
  console.error('错误: 找不到 #root 元素')
  document.body.innerHTML = '<h1 style="color: red; padding: 20px;">错误: 找不到 #root 元素</h1>'
} else {
  ReactDOM.createRoot(rootElement).render(
    <React.StrictMode>
      <App />
    </React.StrictMode>
  )
  console.log('✅ React 应用已挂载')
}
