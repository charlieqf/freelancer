<template>
  <div class="app-container">
    <main-navbar />
    <main class="main-content">
      <router-view />
    </main>
  </div>
</template>

<script>
import MainNavbar from '@/components/layout/Navbar.vue'

export default {
  name: 'MainLayout',
  components: {
    MainNavbar
  }
}
</script>

<style scoped>
.app-container {
  display: flex;
  flex-direction: column;
  min-height: 100vh;
}

.main-content {
  flex: 1;
  padding: 2rem;
  max-width: 1200px;
  margin: 0 auto;
  width: 100%;
}
</style>
