<template>
  <div class="app-container">
    <main-navbar />
    <main class="main-content" :class="{'galaxy-map-route': $route.name === 'GalaxyMap'}">
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

/* 特殊情况：当路由为galaxy-map时，取消宽度限制 */
.galaxy-map-route {
  max-width: 100% !important;
  width: 100vw !important;
  padding: 0 !important;
  margin: 0 !important;
}
</style>
