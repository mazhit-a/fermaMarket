<template>
  <div class="home-container">
    <h2>Admin Panel for the Farm Management System</h2>
    <div class="button-container">
      <router-link to="/login">
        <button>I Already Have an Account</button>
      </router-link>
      <router-link to="/register">
        <button>I Want to Register</button>
      </router-link>
    </div>
  </div>
</template>

<script>
export default {
  name: 'HomePage',
};
</script>

<style scoped>
.home-container {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  height: 100vh;
  background-color: #f9f9f9;
}

.button-container {
  margin-top: 20px;
}

button {
  margin: 5px;
  padding: 10px 15px;
  background-color: #007bff; 
  color: white;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  transition: background-color 0.3s;
}

button:hover {
  background-color: #0056b3;
}
</style>
