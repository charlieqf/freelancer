<template>
  <div class="form-container">
    <h1 class="form-title">修改密码</h1>
    
    <form @submit.prevent="handleSubmit">
      <div class="form-group">
        <label for="currentPassword" class="form-label">当前密码</label>
        <input 
          type="password" 
          id="currentPassword" 
          v-model="form.currentPassword" 
          class="form-input" 
          :class="{ 'input-error': errors.currentPassword }" 
          placeholder="输入当前密码"
          required
          autocomplete="current-password"
        />
        <div v-if="errors.currentPassword" class="form-error">{{ errors.currentPassword }}</div>
      </div>
      
      <div class="form-group">
        <label for="newPassword" class="form-label">新密码</label>
        <input 
          type="password" 
          id="newPassword" 
          v-model="form.newPassword" 
          class="form-input" 
          :class="{ 'input-error': errors.newPassword }" 
          placeholder="输入新密码"
          required
          autocomplete="new-password"
        />
        <div v-if="errors.newPassword" class="form-error">{{ errors.newPassword }}</div>
      </div>
      
      <div class="form-group">
        <label for="confirmPassword" class="form-label">确认新密码</label>
        <input 
          type="password" 
          id="confirmPassword" 
          v-model="form.confirmPassword" 
          class="form-input" 
          :class="{ 'input-error': errors.confirmPassword }" 
          placeholder="再次输入新密码"
          required
          autocomplete="new-password"
        />
        <div v-if="errors.confirmPassword" class="form-error">{{ errors.confirmPassword }}</div>
      </div>
      
      <div v-if="generalError" class="form-error general-error">{{ generalError }}</div>
      <div v-if="successMessage" class="success-message">{{ successMessage }}</div>
      
      <div class="form-actions">
        <button type="submit" class="form-button" :disabled="isLoading">
          {{ isLoading ? '提交中...' : '修改密码' }}
        </button>
        <router-link to="/profile" class="secondary-button">返回个人资料</router-link>
      </div>
    </form>
  </div>
</template>

<script>
import { ref, computed } from 'vue'
import { useStore } from 'vuex'

export default {
  name: 'ChangePasswordPage',
  setup() {
    const store = useStore()
    
    // 表单状态
    const form = ref({
      currentPassword: '',
      newPassword: '',
      confirmPassword: ''
    })
    
    // 错误和成功消息
    const errors = ref({
      currentPassword: '',
      newPassword: '',
      confirmPassword: ''
    })
    const generalError = ref('')
    const successMessage = ref('')
    
    // 从store获取加载状态
    const isLoading = computed(() => store.getters.isLoading)
    
    // 表单验证
    const validateForm = () => {
      // 清除之前的错误
      errors.value.currentPassword = ''
      errors.value.newPassword = ''
      errors.value.confirmPassword = ''
      
      let isValid = true
      
      // 验证当前密码
      if (!form.value.currentPassword) {
        errors.value.currentPassword = '请输入当前密码'
        isValid = false
      }
      
      // 验证新密码
      if (!form.value.newPassword) {
        errors.value.newPassword = '请输入新密码'
        isValid = false
      } else if (form.value.newPassword.length < 8) {
        errors.value.newPassword = '新密码至少需要8个字符'
        isValid = false
      } else if (form.value.newPassword === form.value.currentPassword) {
        errors.value.newPassword = '新密码不能与当前密码相同'
        isValid = false
      }
      
      // 验证确认密码
      if (!form.value.confirmPassword) {
        errors.value.confirmPassword = '请再次输入新密码'
        isValid = false
      } else if (form.value.newPassword !== form.value.confirmPassword) {
        errors.value.confirmPassword = '两次输入的密码不一致'
        isValid = false
      }
      
      return isValid
    }
    
    // 提交表单
    const handleSubmit = async () => {
      // 清除之前的消息
      generalError.value = ''
      successMessage.value = ''
      
      // 验证表单
      if (!validateForm()) return
      
      try {
        // 派发修改密码动作
        await store.dispatch('auth/changePassword', {
          currentPassword: form.value.currentPassword,
          newPassword: form.value.newPassword
        })
        
        // 修改成功，显示成功消息
        successMessage.value = '密码修改成功'
        
        // 清空表单
        form.value.currentPassword = ''
        form.value.newPassword = ''
        form.value.confirmPassword = ''
        
      } catch (error) {
        // 处理错误
        generalError.value = error.response?.data?.message || error.message || '密码修改失败，请稍后重试'
      }
    }
    
    return {
      form,
      errors,
      generalError,
      successMessage,
      isLoading,
      handleSubmit
    }
  }
}
</script>

<style scoped>
.form-actions {
  display: flex;
  gap: 1rem;
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
  flex: 1;
  text-decoration: none;
}

.secondary-button:hover {
  background-color: #e9ecef;
}

.general-error {
  margin-bottom: 1rem;
  text-align: center;
}

.success-message {
  color: #28a745;
  margin-bottom: 1rem;
  text-align: center;
}
</style>
