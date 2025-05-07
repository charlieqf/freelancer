<template>
  <nav class="navbar">
    <div class="navbar-brand">
      <router-link to="/">Freelancer</router-link>
    </div>
    
    <div class="navbar-menu">
      <template v-if="isAuthenticated">
        <!-- 已登录用户菜单 -->
        <div class="navbar-start">
          <router-link to="/dashboard" class="navbar-item">控制面板</router-link>
          <router-link to="/galaxy-map" class="navbar-item">星系地图</router-link>
          <router-link to="/missions" class="navbar-item">任务</router-link>
          <router-link to="/trade" class="navbar-item">交易</router-link>
          <router-link to="/shipyard" class="navbar-item">船坞</router-link>
          <router-link to="/game-saves" class="navbar-item">存档管理</router-link>
        </div>
        
        <div class="navbar-end">
          <div class="navbar-item credits" v-if="currentGameSave">
            <span>游戏币: {{ currentGameSave?.credits || 0 }} 💰</span>
          </div>
          <div class="navbar-item save-name" v-if="currentGameSave">
            <span>当前存档: {{ currentGameSave?.save_name }}</span>
          </div>
          <div class="navbar-item">
            <div class="dropdown">
              <button class="dropdown-trigger">
                <span>{{ currentUser?.username }}</span>
              </button>
              <div class="dropdown-menu">
                <router-link to="/profile" class="dropdown-item">个人资料</router-link>
                <router-link to="/change-password" class="dropdown-item">修改密码</router-link>
                <hr class="dropdown-divider" />
                <button @click="handleLogout" class="dropdown-item">登出</button>
              </div>
            </div>
          </div>
        </div>
      </template>
      
      <template v-else>
        <!-- 未登录用户菜单 -->
        <div class="navbar-end">
          <router-link to="/login" class="navbar-item">登录</router-link>
          <router-link to="/register" class="navbar-item">注册</router-link>
        </div>
      </template>
    </div>
  </nav>
</template>

<script>
import { computed } from 'vue'
import { useStore } from 'vuex'
import { useRouter } from 'vue-router'

export default {
  name: 'MainNavbar',
  setup() {
    const store = useStore()
    const router = useRouter()
    
    // 从store获取认证状态和用户信息
    const isAuthenticated = computed(() => store.getters['auth/isAuthenticated'])
    const currentUser = computed(() => store.getters['auth/currentUser'])
    const currentGameSave = computed(() => store.getters['gameSaves/currentGameSave'])
    
    // 处理登出
    const handleLogout = async () => {
      try {
        await store.dispatch('auth/logout')
        router.push({ name: 'Login' })
      } catch (error) {
        console.error('登出失败:', error)
      }
    }
    
    return {
      isAuthenticated,
      currentUser,
      currentGameSave,
      handleLogout
    }
  }
}
</script>

<style scoped>
/* 导航栏样式可以复用main.css中定义的样式 */
</style>
