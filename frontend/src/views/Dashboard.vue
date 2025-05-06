<template>
  <div class="dashboard">
    <h1>控制面板</h1>
    
    <div class="welcome-message">
      <h2>欢迎回来, {{ currentUser?.username }}!</h2>
      <p>最后登录时间: {{ formatDate(currentUser?.last_login) }}</p>
    </div>
    
    <div class="dashboard-cards">
      <div class="card">
        <h3>游戏状态</h3>
        <div class="card-content">
          <p><strong>游戏币:</strong> {{ currentUser?.credits }} 💰</p>
          <p><strong>声望:</strong> {{ currentUser?.reputation }} ⭐</p>
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
</template>

<script>
import { computed, onMounted } from 'vue'
import { useStore } from 'vuex'

export default {
  name: 'DashboardPage',
  setup() {
    const store = useStore()
    
    // 获取用户信息
    const currentUser = computed(() => store.getters['auth/currentUser'])
    
    // 计算属性
    const currentSystemName = computed(() => 
      currentUser.value?.current_system_id 
        ? `星系 #${currentUser.value.current_system_id}` 
        : '未知'
    )
    
    // 格式化日期
    const formatDate = (dateString) => {
      if (!dateString) return '未知'
      
      const date = new Date(dateString)
      return date.toLocaleString()
    }
    
    // 生命周期钩子
    onMounted(() => {
      // 刷新用户信息
      store.dispatch('auth/fetchUserProfile')
      
      // 这里可以加载飞船、任务等信息
      // 例如：store.dispatch('ships/fetchPlayerShips')
      // 例如：store.dispatch('missions/fetchActiveMissions')
    })
    
    return {
      currentUser,
      currentSystemName,
      formatDate
    }
  }
}
</script>

<style scoped>
.dashboard {
  max-width: 1200px;
  margin: 0 auto;
}

.welcome-message {
  margin-bottom: 2rem;
  padding: 1.5rem;
  background-color: #f8f9fa;
  border-radius: 8px;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.05);
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
