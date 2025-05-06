<template>
  <div class="not-found">
    <h1>404</h1>
    <h2>页面未找到</h2>
    <p>抱歉，您请求的页面不存在。</p>
    <div class="actions">
      <router-link to="/" class="button">返回首页</router-link>
    </div>
  </div>
</template>

<script>
export default {
  name: 'NotFoundPage'
}
</script>

<style scoped>
.not-found {
  text-align: center;
  padding: 3rem 1rem;
  max-width: 500px;
  margin: 0 auto;
}

.not-found h1 {
  font-size: 6rem;
  color: #2a6fc9;
  margin-bottom: 0.5rem;
}

.not-found h2 {
  font-size: 2rem;
  margin-bottom: 1rem;
}

.actions {
  margin-top: 2rem;
}

.button {
  display: inline-block;
  padding: 0.75rem 1.5rem;
  background-color: #2a6fc9;
  color: #fff;
  border-radius: 4px;
  font-weight: 600;
  text-decoration: none;
}

.button:hover {
  background-color: #215aa9;
}
</style>
