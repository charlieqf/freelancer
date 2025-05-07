<template>
  <div class="dashboard">
    <div v-if="!currentGameSave && !loading" class="no-save-state">
      <h1>欢迎来到自由舰长</h1>
      <p>看起来你还没有加载游戏存档。</p>
      <div class="actions">
        <router-link to="/game-saves" class="btn primary-btn">选择存档</router-link>
        <button @click="createNewGameSave" class="btn secondary-btn">创建新存档</button>
      </div>
    </div>

    <div v-else-if="loading" class="loading-state">
      <div class="loading-spinner"></div>
      <p>正在加载游戏数据...</p>
    </div>
    
    <div v-else class="dashboard-content">
      <h1>控制面板</h1>
      
      <div class="welcome-message">
        <h2>欢迎回来, {{ currentUser?.username }}!</h2>
        <div class="game-save-info">
          <p>当前存档: <strong>{{ currentGameSave.save_name }}</strong></p>
          <p>最后游玩时间: {{ formatDate(currentGameSave.last_played_at) }}</p>
        </div>
      </div>
      
      <div class="dashboard-cards">
        <div class="card">
          <h3>游戏状态</h3>
          <div class="card-content">
            <p><strong>游戏币:</strong> {{ currentGameSave.credits }} 💰</p>
            <p><strong>声望:</strong> {{ currentGameSave.reputation }} ⭐</p>
            <p><strong>当前星系:</strong> {{ currentSystemName }}</p>
          </div>
        </div>
        
        <div class="card">
          <h3>飞船情况</h3>
          <div class="card-content">
            <p class="loading-text">- 载入中 -</p>
          </div>
        </div>
        
        <div class="card">
          <h3>任务列表</h3>
          <div class="card-content">
            <p class="loading-text">- 载入中 -</p>
          </div>
        </div>
        
        <div class="card">
          <h3>最近活动</h3>
          <div class="card-content">
            <p class="loading-text">- 载入中 -</p>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { computed, onMounted, ref } from 'vue'
import { useStore } from 'vuex'
import { useRouter } from 'vue-router'

export default {
  name: 'DashboardPage',
  setup() {
    const store = useStore()
    const router = useRouter()
    const loading = ref(true)
    
    // 获取用户和游戏存档信息
    const currentUser = computed(() => store.getters['auth/currentUser'])
    const currentGameSave = computed(() => store.getters['gameSaves/currentGameSave'])
    const gameSavesLoading = computed(() => store.getters['gameSaves/gameSavesLoading'])
    
    // 计算属性
    const currentSystemName = computed(() => {
      if (!currentGameSave.value || !currentGameSave.value.current_system_id) {
        return '未知'
      }
      return `星系 #${currentGameSave.value.current_system_id}`
    })
    
    // 格式化日期
    const formatDate = (dateString) => {
      if (!dateString) return '未知'
      
      const date = new Date(dateString)
      return date.toLocaleString('zh-CN', {
        year: 'numeric',
        month: 'short',
        day: 'numeric',
        hour: '2-digit',
        minute: '2-digit'
      })
    }
    
    // 创建新游戏存档
    const createNewGameSave = async () => {
      router.push('/game-saves')
    }
    
    // 生命周期钩子
    onMounted(async () => {
      // 刷新用户信息
      await store.dispatch('auth/fetchUserProfile')
      
      // 获取游戏存档
      await store.dispatch('gameSaves/fetchGameSaves')
      
      // 尝试自动加载上次游戏存档
      await store.dispatch('gameSaves/autoLoadLastGameSave')
      
      loading.value = false
    })
    
    return {
      currentUser,
      currentGameSave,
      currentSystemName,
      loading: computed(() => loading.value || gameSavesLoading.value),
      formatDate,
      createNewGameSave
    }
  }
}
</script>

<style scoped>
.dashboard {
  max-width: 1200px;
  margin: 0 auto;
}

.dashboard-content {
  width: 100%;
}

.no-save-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  text-align: center;
  padding: 5rem 2rem;
  min-height: 60vh;
}

.no-save-state h1 {
  font-size: 2.5rem;
  margin-bottom: 1rem;
  color: #e6edf3;
}

.no-save-state p {
  font-size: 1.2rem;
  margin-bottom: 2rem;
  color: #8b949e;
}

.actions {
  display: flex;
  gap: 1rem;
}

.btn {
  padding: 0.8rem 1.5rem;
  border-radius: 6px;
  font-size: 1rem;
  cursor: pointer;
  transition: all 0.2s ease;
  text-decoration: none;
  border: none;
  font-weight: 500;
  display: inline-flex;
  align-items: center;
  justify-content: center;
}

.primary-btn {
  background-color: #2ea043;
  color: white;
}

.primary-btn:hover {
  background-color: #3cb551;
}

.secondary-btn {
  background-color: #21262d;
  border: 1px solid #30363d;
  color: #c9d1d9;
}

.secondary-btn:hover {
  background-color: #30363d;
}

.loading-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  min-height: 60vh;
}

.loading-spinner {
  border: 4px solid rgba(255, 255, 255, 0.1);
  border-left: 4px solid #58a6ff;
  border-radius: 50%;
  width: 40px;
  height: 40px;
  animation: spin 1s linear infinite;
  margin-bottom: 1rem;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

.welcome-message {
  margin-bottom: 2rem;
  padding: 1.5rem;
  background-color: rgba(13, 17, 23, 0.7);
  border: 1px solid #30363d;
  border-radius: 8px;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.2);
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.game-save-info {
  display: flex;
  flex-direction: column;
  text-align: right;
  color: #8b949e;
}

.dashboard-cards {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
  gap: 1.5rem;
}

.card {
  background: #fff;
  border-radius: 8px;
  padding: 1.5rem;
  box-shadow: 0 2px 5px rgba(0, 0, 0, 0.1);
}

.card h3 {
  margin-bottom: 1rem;
  color: #1a1a2e;
  border-bottom: 1px solid #eee;
  padding-bottom: 0.5rem;
}

.loading-text {
  color: #6c757d;
  font-style: italic;
}

@media (max-width: 768px) {
  .dashboard-cards {
    grid-template-columns: 1fr;
  }
}
</style>
