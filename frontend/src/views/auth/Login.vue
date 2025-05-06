<template>
  <div class="form-container">
    <h1 class="form-title">用户登录</h1>
    
    <form @submit.prevent="handleSubmit">
      <div class="form-group">
        <label for="username" class="form-label">用户名</label>
        <input 
          type="text" 
          id="username" 
          v-model="form.username" 
          class="form-input" 
          :class="{ 'input-error': errors.username }" 
          placeholder="输入用户名"
          required
          autocomplete="username"
        />
        <div v-if="errors.username" class="form-error">{{ errors.username }}</div>
      </div>
      
      <div class="form-group">
        <label for="password" class="form-label">密码</label>
        <input 
          type="password" 
          id="password" 
          v-model="form.password" 
          class="form-input" 
          :class="{ 'input-error': errors.password }" 
          placeholder="输入密码"
          required
          autocomplete="current-password"
        />
        <div v-if="errors.password" class="form-error">{{ errors.password }}</div>
      </div>
      
      <div v-if="generalError" class="form-error general-error">{{ generalError }}</div>
      
      <button type="submit" class="form-button" :disabled="isLoading">
        {{ isLoading ? '登录中...' : '登录' }}
      </button>
    </form>
    
    <div class="form-link">
      还没有账号？ <router-link to="/register">注册</router-link>
    </div>
  </div>
</template>

<script>
import { ref, computed } from 'vue'
import { useStore } from 'vuex'
import { useRouter } from 'vue-router'

export default {
  name: 'LoginPage',
  setup() {
    const store = useStore()
    const router = useRouter()
    
    // 表单状态
    const form = ref({
      username: '',
      password: ''
    })
    
    // 错误状态
    const errors = ref({
      username: '',
      password: ''
    })
    const generalError = ref('')
    
    // 从store获取加载状态
    const isLoading = computed(() => store.getters.isLoading)
    
    // 表单验证
    const validateForm = () => {
      errors.value.username = form.value.username ? '' : '请输入用户名'
      errors.value.password = form.value.password ? '' : '请输入密码'
      
      return !errors.value.username && !errors.value.password
    }
    
    // 提交表单
    const handleSubmit = async () => {
      // 清除之前的错误
      generalError.value = ''
      
      // 验证表单
      if (!validateForm()) return
      
      try {
        // 派发登录动作
        await store.dispatch('auth/login', {
          username: form.value.username,
          password: form.value.password
        })
        
        // 登录成功，跳转到主页
        router.push({ name: 'Dashboard' })
      } catch (error) {
        // 处理登录错误
        generalError.value = error.response?.data?.message || error.message || '登录失败，请稍后重试'
      }
    }
    
    return {
      form,
      errors,
      generalError,
      isLoading,
      handleSubmit
    }
  }
}
</script>

<style scoped>
.general-error {
  margin-bottom: 1rem;
  text-align: center;
}
</style>
