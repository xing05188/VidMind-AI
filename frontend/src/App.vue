<template>
  <div class="app-stage">
    <header class="navbar">
      <div class="nav-content">
        <div class="brand">
          <span class="brand-do">Vid</span>
          <span class="brand-video">Mind</span>
          <span class="beta-badge">AI</span>
        </div>

        <div class="nav-controls">
          <button v-if="!currentUser" class="auth-btn" @click="openAuthModal">
            <span class="btn-icon">
              <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"></path><circle cx="12" cy="7" r="4"></circle></svg>
            </span>
            登录 / 注册
          </button>

          <div v-else class="user-profile">
            <label class="avatar-wrap" title="点击更换头像">
              <input type="file" accept="image/png,image/jpeg,image/webp,image/gif" class="avatar-input" @change="handleAvatarChange" />
              <img v-if="currentUser.avatar" class="avatar-img" :src="avatarSrc" alt="头像" />
              <span v-else class="avatar-placeholder">{{ avatarLetter }}</span>
            </label>
            <span class="user-name">{{ currentUser.nickname }}</span>
            <button class="logout-btn" @click="logout" title="退出登录">
              <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"></path><polyline points="16 17 21 12 16 7"></polyline><line x1="21" y1="12" x2="9" y2="12"></line></svg>
            </button>
          </div>

          <div class="status-pill" :class="{ 'is-active': uploading }">
            <div class="status-dot"></div>
            <span class="status-text">{{ uploading ? '数据传输中...' : '系统就绪' }}</span>
          </div>
        </div>
      </div>
    </header>

    <main class="main-container">
      <section class="hero-section">
        <h1 class="slogan-main">解码你的视频</h1>
        <p class="slogan-sub">影视智能重构 · AI 算力赋能</p>

        <div class="upload-wrapper">
          <input
              type="file"
              id="file-input"
              @change="handleFileChange"
              accept="video/*"
              hidden
          />

          <div
              class="upload-magnet"
              :class="{ 'processing': uploading, 'is-dragover': isDragOver }"
              @dragover.prevent="isDragOver = true"
              @dragleave.prevent="isDragOver = false"
              @drop.prevent="handleDrop"
          >
            <div class="split-container" v-if="!uploading">

              <label for="file-input" class="skew-pane pane-local">
                <div class="pane-content unskew">
                  <div class="magnet-icon">
                    <svg width="42" height="42" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"></path><polyline points="17 8 12 3 7 8"></polyline><line x1="12" y1="3" x2="12" y2="15"></line></svg>
                  </div>
                  <span class="magnet-title">本地文件</span>
                  <span class="magnet-desc">{{ isDragOver ? '松手上传' : '点击 / 拖拽本地文件' }}</span>
                </div>
              </label>

              <div class="split-gap"></div>

              <div class="skew-pane">
                <div class="pane-content unskew">
                  <div class="magnet-icon">
                    <svg width="42" height="42" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"></circle><line x1="2" y1="12" x2="22" y2="12"></line><path d="M12 2a15.3 15.3 0 0 1 4 10 15.3 15.3 0 0 1-4 10 15.3 15.3 0 0 1 4-10z"></path></svg>
                  </div>
                  <span class="magnet-title">网页链接</span>
                  <span class="magnet-desc">B站 / YouTube / 抖音</span>

                  <div class="url-input-box" @click.stop>
                    <input
                        v-model="videoUrl"
                        type="text"
                        placeholder="粘贴视频链接..."
                        @keyup.enter="handleUrlUpload"
                    />
                    <button class="url-go-btn" @click="handleUrlUpload">
                      <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"><polyline points="9 18 15 12 9 6"></polyline></svg>
                    </button>
                  </div>
                </div>
              </div>

            </div>

            <div class="magnet-content busy" v-else>
              <div class="quantum-loader"></div>
              <span class="busy-text">正在建立通道并解析资源...</span>
            </div>

          </div>
        </div>
        <transition name="toast-pop">
          <div v-if="message" class="notification-bar" :class="{ 'error': messageIsError }">
            {{ message }}
          </div>
        </transition>
      </section>

      <section v-if="list.length > 0" class="workspace-section">
        <div class="section-header"><h3>工作台</h3><div class="count-chip">{{ list.length }} 个任务</div></div>
        <div class="card-grid">
          <div v-for="item in list" :key="item.id" class="project-card">

            <button class="delete-btn" @click.stop="deleteItem(item)" title="删除此项">
              <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                <line x1="18" y1="6" x2="6" y2="18"></line>
                <line x1="6" y1="6" x2="18" y2="18"></line>
              </svg>
            </button>
            <div class="card-meta">
              <div class="meta-icon">
                <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"><polygon points="23 7 16 12 23 17 23 7"></polygon><rect x="1" y="5" width="15" height="14" rx="2" ry="2"></rect></svg>
              </div>
              <div class="meta-info">
                <div class="filename-mask" :title="item.filename">{{ item.filename }}</div>
                <div class="meta-tags">
                  <span class="time-tag">{{ formatTime(item.uploadTime) }}</span>
                  <span class="status-indicator" :class="item.status.toLowerCase()">
                    {{ item.status === 'COMPLETED' ? '已完成' : '处理中' }}
                  </span>
                </div>
              </div>
            </div>

            <div class="action-dock">
              <button class="dock-item" @click="downloadAudio(item)">
                <span class="item-icon">
                  <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"><path d="M9 18V5l12-2v13"></path><circle cx="6" cy="18" r="3"></circle><circle cx="18" cy="16" r="3"></circle></svg>
                </span>
                <span class="item-label">下载音频</span>
              </button>

              <button
                  class="dock-item"
                  :disabled="item.status !== 'COMPLETED'"
                  @click="transcribe(item.id)"
              >
                <span class="item-icon">
                  <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"></path><polyline points="14 2 14 8 20 8"></polyline><line x1="16" y1="13" x2="8" y2="13"></line><line x1="16" y1="17" x2="8" y2="17"></line><polyline points="10 9 9 9 8 9"></polyline></svg>
                </span>
                <span class="item-label">提取文字</span>
              </button>

              <button
                  class="dock-item ai-core"
                  :disabled="item.status !== 'COMPLETED'"
                  @click="openAgent(item)"
              >
                <span class="item-icon">
                  <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"><rect x="4" y="4" width="16" height="16" rx="2" ry="2"></rect><rect x="9" y="9" width="6" height="6"></rect><line x1="9" y1="1" x2="9" y2="4"></line><line x1="15" y1="1" x2="15" y2="4"></line><line x1="9" y1="20" x2="9" y2="23"></line><line x1="15" y1="20" x2="15" y2="23"></line><line x1="20" y1="9" x2="23" y2="9"></line><line x1="20" y1="14" x2="23" y2="14"></line><line x1="1" y1="9" x2="4" y2="9"></line><line x1="1" y1="14" x2="4" y2="14"></line></svg>
                </span>
                <div class="label-group">
                  <span class="item-label">视频智能体</span>
                </div>
              </button>
            </div>
          </div>
        </div>
      </section>

      <div class="sidebar-backdrop" v-if="sidebar.visible" @click="closeSidebar"></div>
      <div class="sidebar-panel" :class="{ 'is-open': sidebar.visible }">
        <div class="sidebar-header">
          <div class="sidebar-title">
            <span class="icon" v-if="sidebar.type === 'ai'">
              <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"><path d="M2 12h2"></path><path d="M20 12h2"></path><path d="M12 2v2"></path><path d="M12 20v2"></path><path d="M20.2 6.47l-1.4 1.4"></path><path d="M15.9 5.35l-1.4-1.4"></path><path d="M9 11a3 3 0 1 0 6 0a3 3 0 0 0-6 0"></path></svg>
            </span>
            <span class="icon" v-else>
              <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"></path><polyline points="14 2 14 8 20 8"></polyline><line x1="16" y1="13" x2="8" y2="13"></line><line x1="16" y1="17" x2="8" y2="17"></line><polyline points="10 9 9 9 8 9"></polyline></svg>
            </span>
            {{ sidebar.title }}
          </div>
          <button class="close-btn" @click="closeSidebar">×</button>
        </div>
        <div class="sidebar-body">
          <div v-if="sidebar.type === 'ai' && sidebar.mode === 'compose'" class="agent-composer">
            <p class="agent-caption">告诉 Agent 你希望从视频中得到什么产物</p>
            <textarea v-model="sidebar.goal" maxlength="500" placeholder="例如：梳理核心观点，给出带时间戳的证据和可执行建议"></textarea>
            <div class="goal-presets">
              <button v-for="preset in goalPresets" :key="preset" @click="sidebar.goal = preset">{{ preset }}</button>
            </div>
            <button class="agent-run-btn" :disabled="!sidebar.goal.trim()" @click="submitAgent">开始分析</button>
          </div>

          <div v-else-if="sidebar.loading" class="agent-running">
            <div class="loading-state"><div class="quantum-loader small"></div><p>Agent 正在分析视频证据...</p></div>
            <div v-if="sidebar.plan?.tasks?.length" class="agent-meta-block">
              <span class="meta-label">任务计划</span>
              <ol><li v-for="task in sidebar.plan.tasks" :key="task">{{ task }}</li></ol>
            </div>
            <div v-if="traceStages.length" class="agent-meta-block">
              <span class="meta-label">已完成阶段</span>
              <div class="stage-list"><span v-for="stage in traceStages" :key="stage[0]">{{ stage[0] }} · {{ stage[1] }}ms</span></div>
            </div>
          </div>

          <div v-else>
            <div v-if="sidebar.type === 'ai'">
              <div class="agent-toolbar">
                <button class="new-chat-btn" @click="startNewConversation" title="清空当前对话并开始新的分析">
                  ＋ 新建对话
                </button>
              </div>
              <div class="markdown-content" v-html="renderedMarkdown"></div>
              <div v-if="sidebar.plan?.tasks?.length || traceStages.length" class="agent-inspector">
                <div v-if="sidebar.plan?.tasks?.length" class="agent-meta-block">
                  <span class="meta-label">规划任务</span>
                  <div v-if="sidebar.editingPlan" class="plan-editor">
                    <div v-for="(_, index) in sidebar.planDraft" :key="index" class="plan-editor-row">
                      <input v-model="sidebar.planDraft[index]" maxlength="500" :aria-label="`任务 ${index + 1}`" />
                      <button type="button" title="删除任务" @click="removePlanTask(index)">×</button>
                    </div>
                    <button v-if="sidebar.planDraft.length < 8" type="button" @click="addPlanTask">添加任务</button>
                    <div class="plan-editor-actions">
                      <button type="button" @click="cancelPlanEdit">取消</button>
                      <button type="button" :disabled="sidebar.rerunLoading" @click="rerunWithPlan">
                        {{ sidebar.rerunLoading ? '提交中' : '按新计划重跑' }}
                      </button>
                    </div>
                  </div>
                  <template v-else>
                    <ol><li v-for="task in sidebar.plan.tasks" :key="task">{{ task }}</li></ol>
                    <button type="button" class="plan-edit-trigger" @click="startPlanEdit">调整计划</button>
                  </template>
                </div>
                <div v-if="traceStages.length" class="agent-meta-block">
                  <span class="meta-label">执行轨迹</span>
                  <div class="stage-list"><span v-for="stage in traceStages" :key="stage[0]">{{ stage[0] }} · {{ stage[1] }}ms</span></div>
                </div>
                <div v-if="sidebar.evaluation && Object.keys(sidebar.evaluation).length" class="quality-row">
                  <span>结构完整 {{ sidebar.evaluation.structuredValid ? '通过' : '待完善' }}</span>
                  <span>证据支持 {{ formatPercent(sidebar.evaluation.evidenceSupportRate) }}</span>
                  <span>评审 {{ sidebar.evaluation.criticPassed ? '通过' : '达到轮次上限' }}</span>
                </div>
              </div>
              <div class="follow-up-box">
                <textarea v-model="sidebar.followUp" maxlength="500" placeholder="基于视频继续追问..."></textarea>
                <button :disabled="sidebar.followUpLoading || !sidebar.followUp.trim()" @click="submitFollowUp">
                  {{ sidebar.followUpLoading ? '分析中' : '追问' }}
                </button>
              </div>
              <div class="feedback-row">
                <span>这个结果有帮助吗？</span>
                <button :class="{ active: sidebar.feedback === 1 }" @click="sendFeedback(1)" title="有帮助">赞</button>
                <button :class="{ active: sidebar.feedback === -1 }" @click="sendFeedback(-1)" title="需改进">踩</button>
              </div>
            </div>
            <div v-else class="text-content"><pre>{{ sidebar.content }}</pre></div>
          </div>
        </div>
      </div>

      <div v-if="showAuthModal" class="auth-backdrop">
        <div class="auth-panel">
          <div class="auth-header">
            <h2 class="auth-title">{{ authMode === 'login' ? '用户登录' : '新用户注册' }}</h2>
            <button class="close-btn" @click="closeAuthModal">×</button>
          </div>
          <div class="auth-body">
            <div class="input-group">
              <label>账 号</label>
              <input v-model="authForm.username" type="text" placeholder="输入账号" />
            </div>
            <div class="input-group">
              <label>密 码</label>
              <input v-model="authForm.password" type="password" placeholder="输入密码" />
            </div>
            <div class="input-group" v-if="authMode === 'register'">
              <label>昵 称</label>
              <input v-model="authForm.nickname" type="text" placeholder="设置一个好听的名字" />
            </div>
            <div class="auth-action">
              <button class="cyber-btn" @click="handleAuth" :disabled="authLoading">
                <span v-if="!authLoading">{{ authMode === 'login' ? '立即登录' : '提交注册' }}</span>
                <span v-else>请求处理中...</span>
              </button>
            </div>
            <div class="auth-toggle">
              <span class="toggle-text">{{ authMode === 'login' ? '没有账号?' : '已有账号?' }}</span>
              <button class="toggle-link" @click="switchAuthMode">{{ authMode === 'login' ? '去注册' : '去登录' }}</button>
            </div>
            <p v-if="authMessage" class="auth-msg" :class="{'error': authError}">{{ authMessage }}</p>
          </div>
        </div>
      </div>
    </main>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, onUnmounted } from 'vue'
import { apiRequest, clearAuthToken, hasAuthToken, setAuthToken } from './api'
import { uploadVideoInChunks } from './chunkUpload'
import { DEMO_ITEM } from './demoData'
import { createTaskStreams } from './taskEvents'
import { useAnalysisWorkspace } from './useAnalysisWorkspace'

// --- 变量定义 ---
const DEMO_MODE = new URLSearchParams(window.location.search).has('demo')
const file = ref(null)
const videoUrl = ref('')
const message = ref('')
const messageIsError = ref(false)
const uploading = ref(false)
const list = ref([])
const isDragOver = ref(false)
const currentUser = ref(null)
const showAuthModal = ref(false)
const authMode = ref('login')
const authLoading = ref(false)
const authMessage = ref('')
const authError = ref(false)
const authForm = ref({ username: '', password: '', nickname: '' })
const taskStreams = createTaskStreams()

// --- 核心业务逻辑 ---

const handleFileChange = async (e) => {
  if (!currentUser.value) {
    e.target.value = ''
    showMsg('⚠️ 权限受限：请先登录系统', true)
    openAuthModal()
    return
  }
  const selectedFile = e.target.files[0]
  if (!selectedFile) return
  if (!selectedFile.type.startsWith('video/')) {
    e.target.value = ''
    showMsg('⚠️ 仅支持上传视频文件', true)
    return
  }
  file.value = selectedFile
  videoUrl.value = ''
  await uploadFile()
}

const handleDrop = async (e) => {
  isDragOver.value = false
  if (!currentUser.value) {
    showMsg('⚠️ 权限受限：请先登录系统', true)
    openAuthModal()
    return
  }
  const droppedFiles = e.dataTransfer.files
  if (!droppedFiles || droppedFiles.length === 0) return
  const selectedFile = droppedFiles[0]
  if (!selectedFile.type.startsWith('video/')) {
    showMsg('⚠️ 仅支持上传视频文件', true)
    return
  }
  file.value = selectedFile
  videoUrl.value = ''
  await uploadFile()
}

const uploadFile = async () => {
  if (!file.value) return
  if (DEMO_MODE) {
    showMsg('演示模式：已模拟完成分片上传')
    return
  }
  uploading.value = true

  try {
    await uploadVideoInChunks(file.value, progress => {
      messageIsError.value = false
      message.value = progress.phase === 'merging'
        ? '分片上传完成，正在合并文件...'
        : `正在上传分片 ${progress.completedChunks}/${progress.totalChunks}...`
    })
    showMsg('✅ 本地上传完成')
    fetchList()
  } catch (error) {
    console.error(error)
    showMsg('❌ 上传失败: ' + error.message, true)
  } finally {
    uploading.value = false
  }
}

const handleUrlUpload = async () => {
  if (!videoUrl.value) return
  if (DEMO_MODE) {
    videoUrl.value = ''
    showMsg('演示模式：已模拟完成链接解析')
    return
  }

  if (!currentUser.value) {
    showMsg('⚠️ 权限受限：请先登录系统', true)
    openAuthModal()
    return
  }

  let parsedUrl
  try {
    parsedUrl = new URL(videoUrl.value)
  } catch {
    parsedUrl = null
  }
  if (!parsedUrl || !['http:', 'https:'].includes(parsedUrl.protocol)) {
    showMsg('⚠️ 请输入合法的 http/https 链接', true)
    return
  }

  uploading.value = true
  messageIsError.value = false
  message.value = '正在解析链接并极速下载 (低码率模式)...'

  const formData = new FormData()
  formData.append('url', videoUrl.value)

  try {
    const res = await apiRequest('/media/upload-url', {
      method: 'POST',
      body: formData
    })
    const text = await res.text()
    if (!res.ok) throw new Error(text)

    showMsg('✅ 链接资源已入库')
    videoUrl.value = ''
    fetchList()
  } catch (error) {
    console.error(error)
    let errMsg = error.message
    if (errMsg.includes("Unsupported URL")) errMsg = "不支持该平台链接"
    showMsg('❌ 解析失败: ' + errMsg, true)
  } finally {
    uploading.value = false
  }
}

const showMsg = (msg, isError = false) => {
  message.value = msg
  messageIsError.value = isError
  setTimeout(() => {
    if (message.value === msg) {
      message.value = ''
      messageIsError.value = false
    }
  }, 4000)
}

const fetchList = async () => {
  if (DEMO_MODE) return
  try {
    let url = '/media/list'
    if (currentUser.value) {
      const timestamp = new Date().getTime()
      url += `?_t=${timestamp}`

      const res = await apiRequest(url)
      if (!res.ok) throw new Error('加载视频列表失败')
      const data = await res.json()
      list.value = data
    } else {
      list.value = []
    }
  } catch (error) {
    console.error(error)
  }
}

const {
  sidebar,
  goalPresets,
  traceStages,
  renderedMarkdown,
  transcribe,
  closeSidebar,
  openAgent,
  startNewConversation,
  getLastAgentMediaId,
  submitAgent,
  showDemoResult,
  startPlanEdit,
  cancelPlanEdit,
  addPlanTask,
  removePlanTask,
  rerunWithPlan,
  submitFollowUp,
  sendFeedback,
  formatPercent
} = useAnalysisWorkspace({
  demoMode: DEMO_MODE,
  taskStreams,
  showMessage: showMsg,
  refreshMediaList: fetchList,
  findMediaItem: id => list.value.find(item => item.id === id)
})

const deleteItem = async (item) => {
  if (DEMO_MODE) {
    list.value = list.value.filter(i => i.id !== item.id)
    showMsg('演示任务已移除')
    return
  }
  if (!confirm(`确认要永久删除 "${item.filename}" 吗？`)) return
  try {
    const res = await apiRequest(`/media/delete?id=${item.id}`, { method: 'DELETE' })
    const text = await res.text()
    if (text === '删除成功') {
      showMsg('文件已销毁')
      list.value = list.value.filter(i => i.id !== item.id)
      // 删除该任务的智能体对话历史缓存
      try { localStorage.removeItem('vidmind_agent_' + item.id) } catch (e) {}
    } else {
      showMsg('❌ ' + text, true)
    }
  } catch (e) {
    showMsg('❌ 删除请求失败', true)
  }
}

const formatTime = (timeStr) => {
  if (!timeStr) return '--'
  const date = new Date(timeStr)
  return `${date.getMonth() + 1}/${date.getDate()} ${String(date.getHours()).padStart(2, '0')}:${String(date.getMinutes()).padStart(2, '0')}`
}

const downloadAudio = async (item) => {
  if (DEMO_MODE) {
    showMsg(`演示模式：${item.filename} 音频已准备`)
    return
  }
  let fileName = item.filename || 'audio.mp3';
  fileName = fileName.replace(/\.[^/.]+$/, "") + ".mp3";
  try {
    showMsg('正在转码并下载...')
    const res = await apiRequest(`/analysis/download?id=${item.id}`)
    if(!res.ok) throw new Error("Fail")
    const blob = await res.blob()
    const downloadUrl = window.URL.createObjectURL(blob)
    const link = document.createElement('a')
    link.href = downloadUrl
    link.download = fileName
    document.body.appendChild(link)
    link.click()
    document.body.removeChild(link)
    window.URL.revokeObjectURL(downloadUrl)
    showMsg('✅ 下载完成')
  } catch (e) {
    alert("下载失败")
  }
}

const openAuthModal = () => {
  showAuthModal.value = true
  authMessage.value = ''
  authForm.value = { username: '', password: '', nickname: '' }
}
const closeAuthModal = () => { showAuthModal.value = false }
const switchAuthMode = () => {
  authMode.value = authMode.value === 'login' ? 'register' : 'login'
  authMessage.value = ''
}
const handleAuth = async () => {
  if (!authForm.value.username || !authForm.value.password) {
    authMessage.value = '请输入完整的账号和密码'
    authError.value = true
    return
  }
  authLoading.value = true
  authMessage.value = ''
  const endpoint = authMode.value === 'login' ? '/user/login' : '/user/register'
  try {
    const res = await apiRequest(endpoint, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(authForm.value)
    })
    const data = await res.json()
    if (data.code === 200) {
      if (authMode.value === 'login') {
        currentUser.value = data.userInfo
        localStorage.setItem('user', JSON.stringify(data.userInfo))
        setAuthToken(data.token)
        closeAuthModal()
        showMsg(`欢迎回来，${data.userInfo.nickname}`)
        fetchList()
      } else {
        authMessage.value = '注册成功，请直接登录'
        authError.value = false
        setTimeout(() => switchAuthMode(), 1000)
      }
    } else {
      authMessage.value = data.msg || '操作失败'
      authError.value = true
    }
  } catch (e) {
    console.error(e)
    authMessage.value = '网络连接错误'
    authError.value = true
  } finally {
    authLoading.value = false
  }
}
const avatarVersion = ref(0)
const avatarSrc = computed(() => {
  if (!currentUser.value || !currentUser.value.id || !currentUser.value.avatar) return ''
  return `/user/avatar/${currentUser.value.id}?_t=${avatarVersion.value}`
})
const avatarLetter = computed(() => {
  const nick = currentUser.value?.nickname || '?'
  return nick.charAt(0).toUpperCase()
})
const handleAvatarChange = async (e) => {
  const selectedFile = e.target.files[0]
  e.target.value = ''
  if (!selectedFile) return
  if (!selectedFile.type.startsWith('image/')) {
    showMsg('⚠️ 请选择图片文件', true)
    return
  }
  if (selectedFile.size > 2 * 1024 * 1024) {
    showMsg('⚠️ 头像图片不能超过 2MB', true)
    return
  }
  const formData = new FormData()
  formData.append('file', selectedFile)
  try {
    const res = await apiRequest('/user/avatar', { method: 'POST', body: formData })
    const data = await res.json()
    if (data.code === 200) {
      currentUser.value = data.userInfo
      localStorage.setItem('user', JSON.stringify(data.userInfo))
      avatarVersion.value++
      showMsg('✅ 头像已更新')
    } else {
      showMsg(`⚠️ ${data.message || '头像上传失败'}`, true)
    }
  } catch (err) {
    showMsg('⚠️ 头像上传失败，请稍后重试', true)
  }
}

const logout = () => {
  if (hasAuthToken()) {
    apiRequest('/user/logout', { method: 'POST' }).catch(() => {})
  }
  taskStreams.stopAll()
  currentUser.value = null
  localStorage.removeItem('user')
  clearAuthToken()
  list.value = []
  showMsg('已退出系统')
}

const handleAuthExpired = () => {
  taskStreams.stopAll()
  currentUser.value = null
  list.value = []
  sidebar.value.visible = false
  localStorage.removeItem('user')
  showMsg('登录状态已失效，请重新登录', true)
  openAuthModal()
}

onMounted(async () => {
  window.addEventListener('auth-expired', handleAuthExpired)
  if (DEMO_MODE) {
    currentUser.value = { id: 1, nickname: 'Agent Demo' }
    list.value = [DEMO_ITEM]
    openAgent(DEMO_ITEM)
    showDemoResult()
    return
  }
  const savedUser = localStorage.getItem('user')
  if (savedUser && hasAuthToken()) {
    try {
      currentUser.value = JSON.parse(savedUser)
    } catch(e) {}
  }
  await fetchList()
  // 刷新页面后自动恢复最近打开的视频智能体对话窗口
  const lastMediaId = getLastAgentMediaId()
  if (lastMediaId) {
    const lastItem = list.value.find(item => item.id === lastMediaId)
    if (lastItem) openAgent(lastItem)
  }
})
onUnmounted(() => {
  window.removeEventListener('auth-expired', handleAuthExpired)
  taskStreams.stopAll()
})
</script>

<style>
/* 确保字体引用在最上方 */
@import url('https://fonts.googleapis.com/css2?family=Noto+Sans+SC:wght@400;500;700&display=swap');

:root {
  --bg-deep: #f5f5f7;
  --bg-card: #ffffff;
  --accent: #0071e3;
  --accent-soft: #e8f1fd;
  --accent-purple: #6e56cf;
  --text-main: #1d1d1f;
  --text-sub: #86868b;
  --text-inverse: #ffffff;
  --border-tech: #e2e2e6;
  --shadow-float: 0 12px 40px -12px rgba(0, 0, 0, 0.18);
  --shadow-glow-lime: 0 8px 24px rgba(0, 113, 227, 0.18);
  --radius: 18px;
}

* { box-sizing: border-box; margin: 0; padding: 0; }

html, body, #app {
  margin: 0 !important; padding: 0 !important; width: 100vw !important;
  max-width: 100vw !important; min-height: 100vh !important;
  overflow-x: hidden; background-color: var(--bg-deep);
  -webkit-font-smoothing: antialiased; -moz-osx-font-smoothing: grayscale;
}

.app-stage { position: relative; z-index: 1; width: 100%; min-height: 100vh; color: var(--text-main); font-family: -apple-system, BlinkMacSystemFont, 'SF Pro Text', 'Noto Sans SC', 'Helvetica Neue', sans-serif; }

::-webkit-scrollbar { width: 9px; height: 9px; }
::-webkit-scrollbar-track { background: transparent; }
::-webkit-scrollbar-thumb { background: #c7c7cc; border-radius: 6px; }
::-webkit-scrollbar-thumb:hover { background: #aeaeb2; }

/* 导航 */
.navbar { position: sticky; top: 0; z-index: 100; width: 100%; padding: 0.85rem 0; background: rgba(255, 255, 255, 0.8); backdrop-filter: saturate(180%) blur(20px); border-bottom: 1px solid var(--border-tech); }
.nav-content { max-width: 1200px; margin: 0 auto; padding: 0 2rem; display: flex; justify-content: space-between; align-items: center; }
.brand { display: flex; align-items: center; gap: 1px; }
.brand-do { font-family: -apple-system, BlinkMacSystemFont, sans-serif; font-size: 1.4rem; color: var(--text-main); font-weight: 700; letter-spacing: -0.5px; }
.brand-video { font-family: -apple-system, BlinkMacSystemFont, sans-serif; font-size: 1.4rem; font-weight: 600; color: var(--accent); letter-spacing: -0.5px; }
.beta-badge { font-size: 0.65rem; font-weight: 600; background: var(--accent-soft); color: var(--accent); padding: 2px 7px; border-radius: 20px; margin-left: 8px; transform: translateY(-6px); }

.nav-controls { display: flex; align-items: center; gap: 14px; }
.auth-btn { background: var(--accent); border: none; color: #fff; padding: 7px 18px; border-radius: 980px; font-family: 'Noto Sans SC', sans-serif; font-weight: 500; cursor: pointer; display: flex; align-items: center; gap: 7px; transition: all 0.25s; font-size: 0.85rem; }
.auth-btn:hover { background: #0077ed; transform: scale(1.02); }
.user-profile { display: flex; align-items: center; gap: 12px; font-family: inherit; font-size: 0.9rem; color: var(--text-main); }
.user-name { color: var(--text-main); font-weight: 500; }
.avatar-wrap { position: relative; display: flex; align-items: center; cursor: pointer; }
.avatar-input { display: none; }
.avatar-img { width: 36px; height: 36px; border-radius: 50%; object-fit: cover; border: 2px solid #fff; box-shadow: 0 0 0 1px var(--border-tech); transition: transform 0.25s; }
.avatar-img:hover { transform: scale(1.06); }
.avatar-placeholder { width: 36px; height: 36px; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-size: 1rem; font-weight: 600; color: #fff; background: linear-gradient(135deg, var(--accent), #42a5f5); border: 2px solid #fff; box-shadow: 0 0 0 1px var(--border-tech); transition: transform 0.25s; }
.avatar-placeholder:hover { transform: scale(1.06); }
.logout-btn { background: none; border: none; color: var(--text-sub); cursor: pointer; padding: 5px; display: flex; align-items: center; transition: color 0.25s; }
.logout-btn:hover { color: #ff3b30; }

.status-pill { display: flex; align-items: center; gap: 8px; background: var(--bg-card); padding: 6px 13px; border-radius: 980px; border: 1px solid var(--border-tech); font-size: 0.78rem; color: var(--text-sub); }
.status-dot { width: 7px; height: 7px; background: #34c759; border-radius: 50%; }
.status-pill.is-active .status-dot { animation: pulse-dot 1.5s infinite alternate; }

/* Hero */
.main-container { max-width: 980px; margin: 0 auto; padding: 4rem 2rem; }
.hero-section { text-align: center; margin-bottom: 5rem; animation: slideUpFade 0.8s forwards; }
.slogan-main {
  font-family: -apple-system, BlinkMacSystemFont, 'Noto Sans SC', sans-serif;
  font-size: clamp(2.4rem, 5.5vw, 3.8rem); font-weight: 700; letter-spacing: -1px;
  margin-bottom: 0.6rem; color: var(--text-main);
}
.slogan-main::after {
  content: ''; display: block; width: 56px; height: 4px; margin: 18px auto 0;
  background: var(--accent); border-radius: 2px;
}
.slogan-sub { font-size: 1.15rem; color: var(--text-sub); letter-spacing: 0.2px; margin-bottom: 2.8rem; font-weight: 400; }

/* === [START] Upload Wrapper (Apple 风) === */
.upload-wrapper { max-width: 760px; margin: 0 auto; opacity: 0; animation: slideUpFade 0.8s 0.2s forwards; }

.upload-magnet {
  position: relative; height: 280px;
  background: var(--bg-card);
  border-radius: var(--radius);
  box-shadow: var(--shadow-float);
  border: 1px solid var(--border-tech);
  overflow: hidden;
  transition: all 0.3s;
}
.upload-magnet:hover { border-color: var(--accent); box-shadow: var(--shadow-glow-lime), var(--shadow-float); transform: translateY(-4px); }

/* 容器布局 */
.split-container {
  display: flex; height: 100%; width: 100%;
  position: relative; overflow: hidden; border-radius: var(--radius);
}

/* 左右面板 (Apple 风，无斜切) */
.skew-pane {
  flex: 1; height: 100%; position: relative; cursor: pointer;
  background: var(--bg-card);
  transition: background 0.3s ease;
  display: flex; align-items: center; justify-content: center;
  z-index: 1;
}

.pane-local { border-right: 1px solid var(--border-tech); }

.skew-pane:hover { background: var(--accent-soft); z-index: 10; }
.split-gap { display: none; }

/* 内容 */
.pane-content {
  display: flex; flex-direction: column; align-items: center;
  z-index: 2; transition: transform 0.3s;
}
.skew-pane:hover .pane-content { transform: scale(1.04); }
.split-container:has(.skew-pane:hover) .skew-pane:not(:hover) { opacity: 0.55; }

.magnet-icon { color: var(--accent); margin-bottom: 1rem; }
.magnet-title { font-size: 1.35rem; font-weight: 600; letter-spacing: 0.3px; margin-bottom: 5px; color: var(--text-main); font-family: 'Noto Sans SC', -apple-system, sans-serif; }
.magnet-desc { font-size: 0.82rem; color: var(--text-sub); }

/* URL 输入框 */
.url-input-box {
  display: flex; margin-top: 16px; border: 1px solid var(--border-tech);
  border-radius: 980px; transition: all 0.25s; position: relative; z-index: 30;
  background: #fff; overflow: hidden;
}
.skew-pane:hover .url-input-box { border-color: var(--accent); }
.url-input-box input {
  background: transparent; border: none; outline: none; color: var(--text-main);
  font-family: inherit; padding: 9px 8px 9px 16px; width: 200px; font-size: 0.9rem;
}
.url-input-box input::placeholder { color: #b0b0b5; }
.url-go-btn {
  background: var(--accent); border: none; color: #fff; cursor: pointer;
  padding: 0 14px; display: flex; align-items: center; justify-content: center; transition: all 0.25s;
}
.url-go-btn:hover { background: #0077ed; }

/* 处理中状态 */
.magnet-content.busy {
  height: 100%; width: 100%; display: flex; flex-direction: column; align-items: center; justify-content: center;
  background: var(--bg-card); position: relative; z-index: 50; color: var(--text-sub);
}
.busy-text { margin-top: 15px; color: var(--accent); animation: pulse-dot 2s infinite; }
/* === [END] === */

.notification-bar { margin-top: 2rem; display: inline-block; background: var(--text-main); color: #fff; padding: 11px 22px; font-weight: 500; border-radius: 980px; font-size: 0.9rem; }
.notification-bar.error { background: #ff3b30; color: #fff; }

.quantum-loader { width: 46px; height: 46px; border: 4px solid var(--border-tech); border-top-color: var(--accent); border-radius: 50%; animation: spin 0.8s linear infinite; margin-bottom: 1rem; }
.quantum-loader.small { width: 30px; height: 30px; margin: 0 auto; }

/* Workspace */
.workspace-section { opacity: 0; animation: slideUpFade 0.8s 0.4s forwards; }
.section-header { display: flex; align-items: center; gap: 12px; margin-bottom: 1.8rem; border-bottom: 1px solid var(--border-tech); padding-bottom: 14px; }
.section-header h3 { font-size: 1.5rem; font-weight: 700; letter-spacing: -0.5px; }
.count-chip { background: var(--accent-soft); color: var(--accent); padding: 4px 11px; border-radius: 980px; font-size: 0.78rem; font-weight: 500; }
.card-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(300px, 1fr)); gap: 18px; }
.project-card { background: var(--bg-card); border-radius: var(--radius); box-shadow: 0 2px 10px rgba(0,0,0,0.06); border: 1px solid var(--border-tech); overflow: hidden; transition: all 0.3s ease; position: relative; }
.project-card::before { display: none; }
.project-card:hover { transform: translateY(-4px); border-color: #cfcfd4; box-shadow: var(--shadow-float); }
.card-meta { display: flex; gap: 1.2rem; padding: 1.4rem; align-items: center; border-bottom: 1px solid var(--border-tech); background: #fafafc; }
.meta-icon { width: 52px; height: 52px; background: var(--accent-soft); border: none; border-radius: 12px; display: flex; align-items: center; justify-content: center; color: var(--accent); }
.filename-mask { font-size: 1.05rem; font-weight: 600; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; max-width: 180px; color: var(--text-main); }
.meta-tags { display: flex; gap: 12px; font-size: 0.82rem; margin-top: 6px; }
.time-tag { color: var(--text-sub); }
.status-indicator { font-weight: 500; padding: 3px 9px; border-radius: 980px; font-size: 0.78rem; }
.status-indicator.completed { color: #1d8a3d; background: #e3f7e8; }
.status-indicator.processing { color: var(--accent); background: var(--accent-soft); animation: blink 1s infinite; }

.action-dock { display: grid; grid-template-columns: 1fr 1fr 1.5fr; gap: 10px; padding: 12px; background: var(--bg-card); }
.dock-item { position: relative; border: 1px solid var(--border-tech); background: var(--bg-card); border-radius: 12px; padding: 15px; display: flex; align-items: center; justify-content: center; gap: 9px; cursor: pointer; transition: all 0.25s; color: var(--text-sub); font-family: inherit; }
.dock-item:hover:not(:disabled) { color: var(--accent); border-color: var(--accent); background: var(--accent-soft); }
.dock-item:disabled { opacity: 0.4; cursor: not-allowed; }
.dock-item.ai-core { border-color: var(--accent); color: var(--accent); }
.dock-item.ai-core .label-group { display: flex; flex-direction: column; align-items: flex-start; z-index: 1; }
.dock-item.ai-core .item-sub { font-size: 0.75rem; color: var(--accent); opacity: 0.85; }
.dock-item.ai-core:hover:not(:disabled) { border-color: var(--accent); color: #fff; background: var(--accent); }
.dock-item.ai-core:hover:not(:disabled) .item-sub { color: rgba(255,255,255,0.9); }

/* Sidebar */
.sidebar-backdrop { position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.3); backdrop-filter: blur(4px); z-index: 998; }
.sidebar-panel { position: fixed; top: 0; right: -600px; width: 550px; max-width: 90vw; height: 100%; background: var(--bg-card); border-left: 1px solid var(--border-tech); z-index: 999; transition: right 0.4s cubic-bezier(0.19, 1, 0.22, 1); display: flex; flex-direction: column; box-shadow: -10px 0 40px rgba(0,0,0,0.12); }
.sidebar-panel.is-open { right: 0; }
.sidebar-header { padding: 20px 30px; border-bottom: 1px solid var(--border-tech); display: flex; justify-content: space-between; align-items: center; background: #fafafc; }
.sidebar-title { font-size: 1.4rem; font-weight: 700; color: var(--text-main); display: flex; align-items: center; gap: 10px; }
.icon { color: var(--accent); display: flex; align-items: center; }
.close-btn { background: none; border: none; color: var(--text-sub); padding: 5px; cursor: pointer; transition: color 0.25s; }
.close-btn:hover { color: var(--accent); }
.sidebar-body { flex: 1; overflow-y: auto; padding: 30px; }
.loading-state { display: flex; flex-direction: column; align-items: center; justify-content: center; height: 100%; color: var(--text-sub); gap: 20px; }
.markdown-content, .text-content { line-height: 1.8; color: var(--text-main); font-size: 0.95rem; }
.text-content pre { white-space: pre-wrap; font-family: ui-monospace, SFMono-Regular, Menlo, monospace; background: #f5f5f7; padding: 15px; border-radius: 10px; border: 1px solid var(--border-tech); color: #333; }
.markdown-content h1, .markdown-content h2, .markdown-content h3 { color: var(--text-main); margin-top: 1.5em; margin-bottom: 0.5em; font-family: -apple-system, BlinkMacSystemFont, sans-serif; }
.markdown-content h1 { border-bottom: 1px solid var(--border-tech); padding-bottom: 10px; }
.markdown-content ul { padding-left: 20px; }
.markdown-content li { margin-bottom: 8px; color: #333; }
.markdown-content strong { color: var(--accent); font-weight: 700; }
.markdown-content p { margin-bottom: 1em; }

/* Agent workspace */
.agent-toolbar { display: flex; justify-content: flex-end; margin-bottom: 14px; }
.new-chat-btn {
  border: 1px solid var(--border-tech); background: transparent; color: var(--text-sub);
  padding: 7px 14px; border-radius: 980px; cursor: pointer; font-family: inherit; font-size: 0.85rem;
  transition: all 0.25s;
}
.new-chat-btn:hover { color: var(--accent); border-color: var(--accent); background: var(--accent-soft); }
.agent-composer { display: flex; flex-direction: column; gap: 18px; }
.agent-caption { color: var(--text-sub); line-height: 1.7; }
.agent-composer textarea, .follow-up-box textarea {
  width: 100%; min-height: 130px; resize: vertical; background: #fff; color: var(--text-main);
  border: 1px solid var(--border-tech); border-radius: 10px; padding: 14px; line-height: 1.6; outline: none;
  font-family: inherit;
}
.agent-composer textarea:focus, .follow-up-box textarea:focus { border-color: var(--accent); box-shadow: 0 0 0 3px var(--accent-soft); }
.goal-presets { display: flex; flex-wrap: wrap; gap: 8px; }
.goal-presets button, .feedback-row button {
  border: 1px solid var(--border-tech); border-radius: 980px; background: transparent; color: var(--text-sub);
  padding: 7px 13px; cursor: pointer; font-family: inherit; font-size: 0.85rem;
}
.goal-presets button:hover, .feedback-row button:hover, .feedback-row button.active {
  color: var(--accent); border-color: var(--accent); background: var(--accent-soft);
}
.agent-run-btn {
  border: 0; border-radius: 980px; padding: 13px 22px; background: var(--accent); color: #fff;
  font-weight: 500; cursor: pointer; font-family: inherit; font-size: 0.95rem;
}
.agent-run-btn:hover:not(:disabled) { background: #0077ed; }
.agent-run-btn:disabled, .follow-up-box button:disabled { opacity: 0.4; cursor: not-allowed; }
.agent-running { display: flex; flex-direction: column; gap: 20px; }
.agent-running .loading-state { min-height: 210px; height: auto; }
.agent-inspector { margin-top: 28px; border-top: 1px solid var(--border-tech); padding-top: 20px; }
.agent-meta-block { margin-bottom: 18px; padding: 14px; background: #f5f5f7; border-radius: 10px; border-left: 3px solid var(--accent); }
.meta-label { display: block; color: var(--accent); font-size: 0.78rem; font-weight: 600; margin-bottom: 10px; }
.agent-meta-block ol { padding-left: 20px; color: #333; }
.agent-meta-block li { margin: 7px 0; }
.plan-editor { display: grid; gap: 8px; margin-top: 12px; }
.plan-editor-row { display: grid; grid-template-columns: minmax(0, 1fr) 34px; gap: 8px; }
.plan-editor input { min-width: 0; border: 1px solid var(--border-tech); background: #fff; color: var(--text-main); padding: 9px 10px; border-radius: 8px; font-family: inherit; }
.plan-editor button, .plan-edit-trigger { border: 1px solid var(--border-tech); background: transparent; color: var(--text-sub); padding: 7px 10px; cursor: pointer; border-radius: 8px; font-family: inherit; }
.plan-editor button:hover, .plan-edit-trigger:hover { color: var(--accent); border-color: var(--accent); }
.plan-editor-actions { display: flex; justify-content: flex-end; gap: 8px; }
.plan-edit-trigger { margin-top: 8px; }
.stage-list { display: flex; flex-wrap: wrap; gap: 8px; }
.stage-list span, .quality-row span {
  border: 1px solid var(--border-tech); border-radius: 8px; padding: 6px 9px; color: var(--text-sub); font-size: 0.78rem; background: #fff;
}
.quality-row { display: flex; flex-wrap: wrap; gap: 8px; }
.follow-up-box { display: grid; grid-template-columns: 1fr auto; gap: 10px; margin-top: 24px; }
.follow-up-box textarea { min-height: 76px; }
.follow-up-box button {
  align-self: stretch; min-width: 76px; border: 1px solid var(--accent); border-radius: 980px;
  background: var(--accent); color: #fff; cursor: pointer; font-family: inherit; font-weight: 500;
}
.follow-up-box button:hover:not(:disabled) { background: #0077ed; }
.feedback-row { display: flex; align-items: center; gap: 8px; margin-top: 18px; color: var(--text-sub); font-size: 0.85rem; }

/* 登录框 */
.auth-backdrop { position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.35); backdrop-filter: blur(6px); z-index: 2000; display: flex; justify-content: center; align-items: center; }
.auth-panel { width: 400px; max-width: 90vw; background: var(--bg-card); border: 1px solid var(--border-tech); border-radius: 20px; box-shadow: 0 20px 50px rgba(0,0,0,0.2); display: flex; flex-direction: column; animation: slideUpFade 0.3s forwards; overflow: hidden; }
.auth-header { padding: 22px; border-bottom: 1px solid var(--border-tech); display: flex; justify-content: space-between; align-items: center; background: #fafafc; }
.auth-title { font-family: 'Noto Sans SC', sans-serif; font-size: 1.2rem; color: var(--text-main); font-weight: 600; }
.auth-body { padding: 30px; }
.input-group { margin-bottom: 20px; }
.input-group label { display: block; font-family: 'Noto Sans SC', sans-serif; color: var(--text-sub); font-size: 0.78rem; margin-bottom: 8px; }
.input-group input { width: 100%; background: #fff; border: 1px solid var(--border-tech); padding: 12px 14px; color: var(--text-main); font-family: inherit; font-size: 1rem; border-radius: 10px; outline: none; transition: all 0.25s; }
.input-group input:focus { border-color: var(--accent); box-shadow: 0 0 0 3px var(--accent-soft); }
.cyber-btn { width: 100%; background: var(--accent); color: #fff; border: none; padding: 13px; font-weight: 500; font-family: 'Noto Sans SC', sans-serif; cursor: pointer; transition: all 0.25s; border-radius: 980px; margin-bottom: 20px; font-size: 0.95rem; }
.cyber-btn:hover:not(:disabled) { background: #0077ed; }
.cyber-btn:disabled { opacity: 0.5; cursor: not-allowed; }
.auth-toggle { text-align: center; font-size: 0.85rem; font-family: 'Noto Sans SC', sans-serif; color: var(--text-sub); }
.toggle-link { background: none; border: none; color: var(--accent); cursor: pointer; font-weight: 500; margin-left: 5px; }
.toggle-link:hover { text-decoration: underline; }
.auth-msg { margin-top: 15px; text-align: center; font-family: 'Noto Sans SC', sans-serif; font-size: 0.82rem; color: var(--accent); }
.auth-msg.error { color: #ff3b30; }

/* 删除按钮 */
.delete-btn {
  position: absolute; top: 10px; right: 10px; background: transparent; border: none;
  color: #b0b0b5; cursor: pointer; opacity: 0; transition: all 0.25s ease; z-index: 10; padding: 5px;
}
.project-card:hover .delete-btn { opacity: 1; }
.delete-btn:hover { color: #ff3b30; transform: scale(1.15); }

@media (max-width: 720px) {
  .navbar { padding: 0.8rem 0; }
  .nav-content { padding: 0 1rem; }
  .brand-do, .brand-video { font-size: 1.25rem; }
  .status-pill { display: none; }
  .auth-btn { padding: 6px 10px; }
  .main-container { padding: 2.5rem 1rem; }
  .hero-section { margin-bottom: 3rem; }
  .slogan-main { font-size: 2rem; }
  .slogan-sub { margin-bottom: 2rem; }
  .upload-magnet { height: auto; min-height: 420px; border-radius: 14px; }
  .split-container { flex-direction: column; }
  .skew-pane { min-height: 210px; }
  .pane-local { border-right: none; border-bottom: 1px solid var(--border-tech); }
  .card-grid { grid-template-columns: 1fr; }
  .action-dock { grid-template-columns: 1fr; }
  .filename-mask { max-width: 55vw; }
  .sidebar-panel { width: 100%; max-width: 100vw; right: -100vw; }
  .sidebar-header { padding: 16px 18px; }
  .sidebar-title { font-size: 1rem; max-width: calc(100vw - 70px); overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
  .sidebar-body { padding: 20px 16px; }
  .follow-up-box { grid-template-columns: 1fr; }
  .follow-up-box button { min-height: 44px; }
}

@keyframes spin { to { transform: rotate(360deg); } }
@keyframes slideUpFade { from { opacity: 0; transform: translateY(40px); } to { opacity: 1; transform: translateY(0); } }
@keyframes pulse-dot { 0% { opacity: 0.4; } 100% { opacity: 1; } }
@keyframes blink { 50% { opacity: 0.4; } }
</style>
