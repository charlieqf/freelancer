<template>
  <div class="form-container">
    <h1 class="form-title">用户注册</h1>
    
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
        <label for="email" class="form-label">电子邮箱</label>
        <input 
          type="email" 
          id="email" 
          v-model="form.email" 
          class="form-input" 
          :class="{ 'input-error': errors.email }" 
          placeholder="输入电子邮箱"
          required
          autocomplete="email"
        />
        <div v-if="errors.email" class="form-error">{{ errors.email }}</div>
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
          autocomplete="new-password"
        />
        <div v-if="errors.password" class="form-error">{{ errors.password }}</div>
      </div>
      
      <div class="form-group">
        <label for="confirmPassword" class="form-label">确认密码</label>
        <input 
          type="password" 
          id="confirmPassword" 
          v-model="form.confirmPassword" 
          class="form-input" 
          :class="{ 'input-error': errors.confirmPassword }" 
          placeholder="再次输入密码"
          required
          autocomplete="new-password"
        />
        <div v-if="errors.confirmPassword" class="form-error">{{ errors.confirmPassword }}</div>
      </div>
      
      <div class="form-group">
        <label for="faction" class="form-label">选择阵营</label>
        <select 
          id="faction" 
          v-model="form.factionId" 
          class="form-input" 
          :class="{ 'input-error': errors.factionId }"
          required
        >
          <option value="" disabled>-- 选择阵营 --</option>
          <option v-for="faction in factions" :key="faction.id" :value="faction.id">
            {{ faction.name }}
          </option>
        </select>
        <div v-if="errors.factionId" class="form-error">{{ errors.factionId }}</div>
      </div>
      
      <div v-if="generalError" class="form-error general-error">{{ generalError }}</div>
      
      <button type="submit" class="form-button" :disabled="isLoading">
        {{ isLoading ? '注册中...' : '注册' }}
      </button>
    </form>
    
    <div class="form-link">
      已有账号？ <router-link to="/login">登录</router-link>
    </div>
  </div>
</template>

<script>
import { ref, computed, onMounted } from 'vue'
import { useStore } from 'vuex'
import { useRouter } from 'vue-router'

export default {
  name: 'RegisterPage',
  setup() {
    const store = useStore()
    const router = useRouter()
    
    // 表单状态
    const form = ref({
      username: '',
      email: '',
      password: '',
      confirmPassword: '',
      factionId: ''
    })
    
    // 错误状态
    const errors = ref({
      username: '',
      email: '',
      password: '',
      confirmPassword: '',
      factionId: ''
    })
    const generalError = ref('')
    
    // 阵营列表
    const factions = ref([
      { id: 1, name: '联邦政府' },
      { id: 2, name: '商业联盟' },
      { id: 3, name: '独立贸易商' },
      { id: 4, name: '边缘同盟' }
    ])
    
    // 从store获取加载状态
    const isLoading = computed(() => store.getters.isLoading)
    
    // 表单验证
    const validateForm = () => {
      // 清除之前的错误
      errors.value.username = ''
      errors.value.email = ''
      errors.value.password = ''
      errors.value.confirmPassword = ''
      errors.value.factionId = ''
      
      let isValid = true
      
      // 验证用户名
      if (!form.value.username) {
        errors.value.username = '请输入用户名'
        isValid = false
      } else if (form.value.username.length < 3) {
        errors.value.username = '用户名至少需要3个字符'
        isValid = false
      }
      
      // 验证邮箱
      if (!form.value.email) {
        errors.value.email = '请输入电子邮箱'
        isValid = false
      } else if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(form.value.email)) {
        errors.value.email = '请输入有效的电子邮箱地址'
        isValid = false
      }
      
      // 验证密码
      if (!form.value.password) {
        errors.value.password = '请输入密码'
        isValid = false
      } else if (form.value.password.length < 8) {
        errors.value.password = '密码至少需要8个字符'
        isValid = false
      }
      
      // 验证确认密码
      if (!form.value.confirmPassword) {
        errors.value.confirmPassword = '请再次输入密码'
        isValid = false
      } else if (form.value.password !== form.value.confirmPassword) {
        errors.value.confirmPassword = '两次输入的密码不一致'
        isValid = false
      }
      
      // 验证阵营
      if (!form.value.factionId) {
        errors.value.factionId = '请选择阵营'
        isValid = false
      }
      
      return isValid
    }
    
    // 提交表单
    const handleSubmit = async () => {
      // 清除之前的错误
      generalError.value = ''
      
      // 验证表单
      if (!validateForm()) return
      
      try {
        // 派发注册动作
        await store.dispatch('auth/register', {
          username: form.value.username,
          email: form.value.email,
          password: form.value.password,
          factionId: form.value.factionId
        })
        
        // 注册成功，跳转到主页
        router.push({ name: 'Dashboard' })
      } catch (error) {
        // 处理注册错误
        generalError.value = error.response?.data?.message || error.message || '注册失败，请稍后重试'
      }
    }
    
    // 生命周期钩子
    onMounted(() => {
      // 可以在这里加载阵营数据
      // 例如: store.dispatch('factions/fetchFactions')
    })
    
    return {
      form,
      errors,
      generalError,
      factions,
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
