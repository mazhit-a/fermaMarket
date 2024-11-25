<template>
  <nav class="navbar">
    <div class="navbar-container">
      <router-link to="/panel" class="navbar-link">Admin Panel</router-link>
      <router-link to="/management" class="navbar-link">User Management</router-link>
    </div>
    <button @click="logout" class="navbar-link logout-btn">Log Out</button>
  </nav>
</template>

<script>
import axios from 'axios';
axios.defaults.withCredentials = true;
export default {
  methods: {
    async logout() {
      try {
        const response = await axios.post('http://localhost:3003/api/logout', { withCredentials: true });
        if (response.status === 200) {
          localStorage.removeItem('token');
          this.$router.push('/login'); 
        }
      } catch (error) {
        console.error('Logout failed:', error);
      }
    }
  }
}
</script>

<style scoped>
.navbar {
  background-color: #333;
  padding: 15px 20px;
  display: flex;
  justify-content: space-between;
  align-items: center;
  color: white;
  border-radius: 20px;
  box-shadow: 0 2px 10px rgb(63, 49, 49);
}

.navbar-container {
  display: flex;
  gap: 20px;
}

.navbar-link {
  color: white;
  text-decoration: none;
  font-size: 1.1em;
  padding: 8px 16px;
  border-radius: 5px;
  transition: background-color 0.3s, color 0.3s;
}

.navbar-link:hover {
  background-color: #6b6b6b;
  color: white;
  text-decoration: none;
}

.logout-btn {
  background-color: #6c302b;
  color: white;
  padding: 8px 15px;
  border: none;
  border-radius: 5px;
  cursor: pointer;
  transition: background-color 0.3s;
}

.logout-btn:hover {
  background-color: #783736;
}

@media (max-width: 768px) {
  .navbar {
    background-color: #333;
    padding: 5px 5px;
    display: flex;
    justify-content: space-between;
    align-items: center;
    color: white;
    border-radius: 10px;
  }

  .navbar-container {
    display: flex;
    gap: 0px;
  }

  .navbar-link {
    color: white;
    text-decoration: none;
    font-size: 0.9em;
    padding: 5px 5px;
    border-radius: 5px;
  }
}
</style>