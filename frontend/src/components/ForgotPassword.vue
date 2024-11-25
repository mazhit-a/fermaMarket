<template>
  <div class="forgot-password-page">
    <h2>Reset Your Password</h2>
    <form @submit.prevent="sendRecoveryEmail" class="forgot-password-form">
      <input v-model="email" type="email" placeholder="Enter your email" required class="input-field"/>
      <button type="submit" class="submit-button">Send Recovery Email</button>
    </form>
    <p v-if="message" class="response-message">{{ message }}</p>
  </div>
</template>

<script>
import axios from 'axios';

export default {
  data() {
    return {
      email: '',
      message: '',
    };
  },
  methods: {
    async sendRecoveryEmail() {
      try {
        const response = await axios.post('http://localhost:3003/api/forgot-password', { email: this.email });
        this.message = response.data.message;
      } catch (error) {
        this.message = error.response.data.message || 'Something went wrong. Please try again.';
      }
    },
  },
};
</script>

<style scoped>
.forgot-password-page {
  max-width: 400px;
  margin: 50px auto;
  padding: 20px;
  text-align: center;
  font-family: Arial, sans-serif;
  border: 1px solid #ddd;
  border-radius: 8px;
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
  background-color: #f9f9f9;
}

h2 {
  color: #333;
  margin-bottom: 20px;
}

.forgot-password-form {
  display: flex;
  flex-direction: column;
}

.input-field {
  padding: 10px;
  margin-bottom: 15px;
  border: 1px solid #ccc;
  border-radius: 4px;
  font-size: 16px;
  width: 100%;
  box-sizing: border-box;
}

.submit-button {
  padding: 10px 15px;
  background-color: #4CAF50;
  color: white;
  border: none;
  border-radius: 4px;
  font-size: 16px;
  cursor: pointer;
  transition: background-color 0.3s ease;
}

.submit-button:hover {
  background-color: #45a049;
}

.response-message {
  margin-top: 20px;
  font-size: 14px;
  color: #444;
}
</style>
