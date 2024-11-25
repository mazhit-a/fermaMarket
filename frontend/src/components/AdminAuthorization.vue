<template>
    <div class="container">
      <h2>Login</h2>
      <form @submit.prevent="loginUser">
        <input v-model="username" placeholder="Username" required />
        <input v-model="password" type="password" placeholder="Password" required />
        <button type="submit" :disabled="loading">{{ loading ? 'Logging in...' : 'Login' }}</button>
        <router-link to="/register">
            <button style="margin-top: 20px;">I do not have an account</button>
        </router-link>
        <p v-if="errorMessage" class="error-message">{{ errorMessage }}</p>
      </form>
      <button @click="goToForgotPassword" id="no-hover" class="forgot-password">Forgot Password?</button>
    </div>
</template>

<script>
  import axios from 'axios';
  import { useRouter } from 'vue-router';
  
  export default {
    data() {
    return {
      username: '',
      password: '',
      loading: false,
      errorMessage: '', 
    };
  },
    setup() {
      const router = useRouter();
      return { router };
    },
    methods: {
      goToForgotPassword() {
      this.$router.push({ name: 'ForgotPassword' });
    },
      async loginUser() {
      this.loading = true; 
      this.errorMessage = ''; 

      try {
        const response = await axios.post('http://localhost:3003/api/login', {
          username: this.username,
          password: this.password,
        });
        console.log('Login successful:', response.data);
        this.router.push({ name: 'Panel' });
      } catch (error) {
        this.loading = false;
        console.error('Login failed:', error.response.data);
        
        this.errorMessage = 'Wrong username or password. Please try again.';
      }
    },
    },
  };
</script>
  
<style scoped>
  .container {
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    height: 100vh;
    background-color: #f9f9f9;
  }
  
  form {
    background: white;
    padding: 20px;
    border-radius: 8px;
    box-shadow: 0 4px 10px rgba(0, 0, 0, 0.1);
    width: 300px;
  }
  
  input {
    width: 100%;
    padding: 10px;
    margin: 10px 0;
    border: 1px solid #ccc;
    border-radius: 4px;
  }
  
  button {
    width: 100%;
    padding: 10px;
    background-color: #007bff;
    color: white;
    border: none;
    border-radius: 4px;
    cursor: pointer;
    transition: background-color 0.3s;
  }
  
  button:not(#no-hover):hover {
    background-color: #0056b3;
  }
  
  .error-message {
    color: red;
    margin-top: 10px;
  }

  .forgot-password {
    background: none;
    color: blue;
    border: none;
    cursor: pointer;
    text-decoration: underline;
  }
</style>