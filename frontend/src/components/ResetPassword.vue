<template>
  <div class="reset-password-page">
    <h2>Reset Your Password</h2>
    <form @submit.prevent="resetPassword" class="reset-password-form">
      <input v-model="password" type="password" placeholder="New password" required class="input-field"/>
      <input v-model="confirmPassword" type="password" placeholder="Confirm password" required class="input-field"/>
      <button type="submit" class="submit-button">Reset Password</button>
    </form>
    <p v-if="message" class="response-message">{{ message }}</p>
  </div>
</template>

<script>
import axios from 'axios';
import { useRoute, useRouter } from 'vue-router';

export default {
  data() {
    return {
      password: '',
      confirmPassword: '',
      message: '',
    };
  },
  setup() {
    const route = useRoute();
    const router = useRouter();
    return { route, router };
  },
  methods: {
    async resetPassword() {
      if (this.password !== this.confirmPassword) {
        this.message = 'Passwords do not match';
        return;
      }

      try {
        const token = this.route.params.token;
        await axios.post(`http://localhost:3003/api/reset-password/${token}`, { password: this.password });
        this.message = 'Password reset successfully!';
        setTimeout(() => this.router.push({ name: 'Login' }), 2000);
      } catch (error) {
        this.message = error.response?.data?.message || 'Password reset failed.';
      }
    },
  },
};
</script>

<style scoped>
.reset-password-page {
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

.reset-password-form {
  display: flex;
  flex-direction: column;
}

.input-field {
  padding: 10px;
  margin: 10px 0;
  font-size: 14px;
  border: 1px solid #ccc;
  border-radius: 4px;
}

.submit-button {
  padding: 10px 15px;
  margin-top: 15px;
  font-size: 16px;
  background-color: #4CAF50;
  color: white;
  border: none;
  border-radius: 4px;
  cursor: pointer;
}

.submit-button:hover {
  background-color: #45a049;
}

.response-message {
  margin-top: 20px;
  color: #f44336;
  font-weight: bold;
}

.response-message.success {
  color: #4CAF50;
}
</style>
