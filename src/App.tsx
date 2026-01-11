import React from 'react'

function App() {
  return (
    <div style={{
      minHeight: '100vh',
      background: 'linear-gradient(135deg, #1a2a3a 0%, #0d1824 100%)',
      color: 'white',
      padding: '20px',
      textAlign: 'center',
      fontFamily: 'Arial, sans-serif'
    }}>
      <h1 style={{ 
        color: '#d4af37', 
        fontSize: '3rem',
        marginTop: '2rem'
      }}>
        🎮 番摊模拟器
      </h1>
      
      <p style={{ fontSize: '1.2rem', opacity: 0.8 }}>
        广东传统游戏概率模拟与可视化系统
      </p>
      
      <div style={{
        maxWidth: '600px',
        margin: '3rem auto',
        padding: '2rem',
        background: 'rgba(0, 0, 0, 0.3)',
        borderRadius: '15px',
        border: '2px solid #d4af37'
      }}>
        <h2>✅ 项目运行正常！</h2>
        
        <div style={{ 
          display: 'grid', 
          gridTemplateColumns: '1fr 1fr', 
          gap: '10px',
          margin: '2rem 0'
        }}>
          {[1, 2, 3, 4].map(num => (
            <button
              key={num}
              style={{
                padding: '2rem',
                fontSize: '2rem',
                background: 'rgba(212, 175, 55, 0.2)',
                border: '2px solid #d4af37',
                borderRadius: '10px',
                color: 'white',
                cursor: 'pointer'
              }}
            >
              {num}
            </button>
          ))}
        </div>
        
        <div style={{ marginTop: '2rem' }}>
          <h3>💰 当前余额: ¥1000</h3>
          <p style={{ marginTop: '1rem' }}>
            点击上方数字进行下注，体验传统番摊游戏
          </p>
        </div>
      </div>
      
      <div style={{
        marginTop: '3rem',
        padding: '1.5rem',
        background: 'rgba(255, 255, 255, 0.05)',
        borderRadius: '10px'
      }}>
        <h3>📊 部署说明</h3>
        <p>项目已成功配置，现在可以部署到 GitHub Pages：</p>
        <code style={{
          display: 'block',
          background: '#1a1a1a',
          padding: '1rem',
          margin: '1rem auto',
          borderRadius: '5px',
          maxWidth: '400px'
        }}>
          npm run build && npm run deploy
        </code>
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
