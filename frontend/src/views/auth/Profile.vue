<template>
  <div class="profile-container">
    <h1 class="page-title">个人资料</h1>
    
    <div class="profile-info">
      <div class="profile-avatar">
        <img :src="userAvatar" alt="用户头像" class="avatar-img" />
        <div class="avatar-overlay">
          <button @click="openFileInput" class="avatar-btn">更换头像</button>
          <input 
            type="file" 
            ref="fileInput" 
            accept="image/*" 
            style="display: none" 
            @change="handleAvatarChange"
          />
        </div>
      </div>
      
      <div class="profile-details">
        <form @submit.prevent="updateProfile">
          <div class="form-group">
            <label for="username" class="form-label">用户名</label>
            <input 
              type="text" 
              id="username" 
              v-model="user.username" 
              class="form-input" 
              disabled
            />
            <small class="form-text">用户名不可更改</small>
          </div>
          
          <div class="form-group">
            <label for="email" class="form-label">电子邮箱</label>
            <input 
              type="email" 
              id="email" 
              v-model="form.email" 
              class="form-input" 
              :class="{ 'input-error': errors.email }" 
              placeholder="输入电子邮箱"
              required
            />
            <div v-if="errors.email" class="form-error">{{ errors.email }}</div>
          </div>
          
          <div class="form-group">
            <label for="faction" class="form-label">阵营</label>
            <input 
              type="text" 
              id="faction" 
              :value="factionName" 
              class="form-input" 
              disabled
            />
            <small class="form-text">阵营不可更改</small>
          </div>
          
          <div v-if="generalError" class="form-error general-error">{{ generalError }}</div>
          <div v-if="successMessage" class="success-message">{{ successMessage }}</div>
          
          <div class="form-actions">
            <button type="submit" class="form-button" :disabled="isLoading">
              {{ isLoading ? '更新中...' : '更新资料' }}
            </button>
            <router-link to="/change-password" class="secondary-button">修改密码</router-link>
          </div>
        </form>
      </div>
    </div>
    
    <div class="player-stats">
      <h2>游戏数据</h2>
      
      <div class="stats-grid">
        <div class="stats-item">
          <span class="stats-label">游戏币</span>
          <span class="stats-value">{{ user.credits }} 💰</span>
        </div>
        
        <div class="stats-item">
          <span class="stats-label">声望</span>
          <span class="stats-value">{{ user.reputation }} ⭐</span>
        </div>
        
        <div class="stats-item">
          <span class="stats-label">当前星系</span>
          <span class="stats-value">{{ currentSystemName }}</span>
        </div>
        
        <div class="stats-item">
          <span class="stats-label">注册日期</span>
          <span class="stats-value">{{ formatDate(user.created_at) }}</span>
        </div>
        
        <div class="stats-item">
          <span class="stats-label">最后登录</span>
          <span class="stats-value">{{ formatDate(user.last_login) }}</span>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { ref, computed, onMounted } from 'vue'
import { useStore } from 'vuex'

export default {
  name: 'ProfilePage',
  setup() {
    const store = useStore()
    const fileInput = ref(null)
    
    // 用户信息
    const user = computed(() => store.getters['auth/currentUser'] || {})
    
    // 表单状态
    const form = ref({
      email: '',
      avatarUrl: ''
    })
    
    // 错误和成功消息
    const errors = ref({ email: '' })
    const generalError = ref('')
    const successMessage = ref('')
    
    // 阵营映射
    const factions = {
      1: '联邦政府',
      2: '商业联盟',
      3: '独立贸易商',
      4: '边缘同盟'
    }
    
    // 计算属性
    const isLoading = computed(() => store.getters.isLoading)
    const factionName = computed(() => factions[user.value?.faction_id] || '未知')
    const currentSystemName = computed(() => `星系 #${user.value?.current_system_id || '未知'}`)
    const userAvatar = computed(() => 
      user.value?.avatar_url || 'https://via.placeholder.com/150?text=无头像'
    )
    
    // 方法
    const openFileInput = () => {
      fileInput.value.click()
    }
    
    const handleAvatarChange = (event) => {
      const file = event.target.files[0]
      if (file) {
        const reader = new FileReader()
        reader.onload = (e) => {
          // 这里应该上传图片到服务器，获取URL
          // 现在仅演示更新本地状态
          form.value.avatarUrl = e.target.result
        }
        reader.readAsDataURL(file)
      }
    }
    
    const validateForm = () => {
      errors.value.email = ''
      
      if (!form.value.email) {
        errors.value.email = '请输入电子邮箱'
        return false
      } else if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(form.value.email)) {
        errors.value.email = '请输入有效的电子邮箱地址'
        return false
      }
      
      return true
    }
    
    const updateProfile = async () => {
      // 清除消息
      generalError.value = ''
      successMessage.value = ''
      
      // 验证表单
      if (!validateForm()) return
      
      try {
        // 更新用户资料
        const userData = {
          email: form.value.email
        }
        
        if (form.value.avatarUrl) {
          userData.avatar_url = form.value.avatarUrl
        }
        
        await store.dispatch('auth/updateUserProfile', userData)
        
        // 显示成功消息
        successMessage.value = '个人资料已更新'
      } catch (error) {
        // 处理错误
        generalError.value = error.response?.data?.message || error.message || '更新失败，请稍后重试'
      }
    }
    
    const formatDate = (dateString) => {
      if (!dateString) return '未知'
      
      const date = new Date(dateString)
      return date.toLocaleString()
    }
    
    // 生命周期钩子
    onMounted(() => {
      // 初始化表单数据
      if (user.value) {
        form.value.email = user.value.email || ''
      }
      
      // 刷新用户信息
      store.dispatch('auth/fetchUserProfile')
    })
    
    return {
      user,
      form,
      errors,
      generalError,
      successMessage,
      isLoading,
      factionName,
      currentSystemName,
      userAvatar,
      fileInput,
      openFileInput,
      handleAvatarChange,
      updateProfile,
      formatDate
    }
  }
}
</script>

<style scoped>
.profile-container {
  max-width: 800px;
  margin: 0 auto;
}

.page-title {
  margin-bottom: 2rem;
  border-bottom: 1px solid #eee;
  padding-bottom: 1rem;
}

.profile-info {
  display: flex;
  margin-bottom: 2rem;
}

.profile-avatar {
  position: relative;
  width: 150px;
  height: 150px;
  margin-right: 2rem;
}

.avatar-img {
  width: 100%;
  height: 100%;
  object-fit: cover;
  border-radius: 50%;
}

.avatar-overlay {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  border-radius: 50%;
  background-color: rgba(0, 0, 0, 0.5);
  display: flex;
  align-items: center;
  justify-content: center;
  opacity: 0;
  transition: opacity 0.3s;
}

.profile-avatar:hover .avatar-overlay {
  opacity: 1;
}

.avatar-btn {
  background-color: white;
  border: none;
  border-radius: 4px;
  padding: 0.5rem 1rem;
  cursor: pointer;
}

.profile-details {
  flex: 1;
}

.form-text {
  font-size: 0.75rem;
  color: #666;
}

.form-actions {
  display: flex;
  gap: 1rem;
  margin-top: 1rem;
}

.secondary-button {
  display: block;
  padding: 0.75rem;
  background-color: #f8f9fa;
  color: #333;
  border: 1px solid #ddd;
  border-radius: 4px;
  font-size: 1rem;
  cursor: pointer;
  text-align: center;
  text-decoration: none;
}

.secondary-button:hover {
  background-color: #e9ecef;
}

.general-error {
  margin-bottom: 1rem;
}

.success-message {
  color: #28a745;
  margin-bottom: 1rem;
}

.player-stats {
  background-color: #f8f9fa;
  border-radius: 8px;
  padding: 1.5rem;
}

.stats-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
  gap: 1rem;
  margin-top: 1rem;
}

.stats-item {
  display: flex;
  flex-direction: column;
  padding: 1rem;
  background-color: white;
  border-radius: 4px;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
}

.stats-label {
  font-size: 0.875rem;
  color: #666;
  margin-bottom: 0.5rem;
}

.stats-value {
  font-weight: bold;
  font-size: 1.25rem;
}

@media (max-width: 576px) {
  .profile-info {
    flex-direction: column;
    align-items: center;
  }
  
  .profile-avatar {
    margin-right: 0;
    margin-bottom: 1.5rem;
  }
}
</style>
