<template>
  <div id="app">
    <AppNavbar v-if="showNavbar" />
    <router-view />
  </div>
</template>

<script>
import AppNavbar from './components/AppNavbar.vue';

export default {
  name: 'App',
  components: {
    AppNavbar,
  },
  computed: {
    showNavbar() {
      const hiddenRoutes = ['Login', 'Register', 'Home', 'ForgotPassword', 'ResetPassword'];
      return !hiddenRoutes.includes(this.$route.name); 
    },
  },
};
</script>

<style>
#app {
  font-family: Avenir, Helvetica, Arial, sans-serif;
  text-align: center;
  color: #2c3e50;
}


</style>

