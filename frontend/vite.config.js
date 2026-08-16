import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'

// https://vite.dev/config/
export default defineConfig({
  plugins: [vue()],
  server: {
    // 绑定所有网卡，允许通过公网 IP 访问
    host: '0.0.0.0',
    proxy: {
      // 后端接口无统一前缀，按 Controller 前缀逐个代理到后端 9090
      '/user': proxyTarget('http://localhost:9090'),
      '/media': proxyTarget('http://localhost:9090'),
      '/analysis': proxyTarget('http://localhost:9090'),
      '/admin': proxyTarget('http://localhost:9090'),
    },
  },
})

// 同源代理：转发时移除 Origin 头，避免后端 CORS 白名单拦截公网来源
function proxyTarget(target) {
  return {
    target,
    changeOrigin: true,
    configure: (proxy) => {
      proxy.on('proxyReq', (proxyReq) => {
        proxyReq.removeHeader('origin')
      })
    },
  }
}
