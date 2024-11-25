<template>
    <div class="edit-user-container">
      <h1>Edit User</h1>
      <form @submit.prevent="updateUser" class="edit-user-form">

        <div class="form-group">
          <label for="name">Name:</label>
          <input type="text" id="name" v-model="user.name" required class="form-input" />
        </div>

        <div class="form-group">
          <label for="email">Email:</label>
          <input type="text" id="email" v-model="user.email" required class="form-input" />
        </div>

        <div class="form-group"> 
          <label for="phone_number">Phone number:</label>
          <input type="text" id="phone_number" v-model="user.phone_number" required class="form-input" />
        </div>

        <div v-if="type === 'buyer'" class="form-group"> 
          <label for="delivery_address">Delivery address:</label>
          <input type="text" id="delivery_address" v-model="user.delivery_address" required class="form-input" />
        </div>

        <div v-if="type === 'farmer'" class="form-group">  
          <label for="gov_id">Governmental ID:</label> 
          <input type="text" id="gov_id" v-model="user.gov_id" required class="form-input" /> 
        </div>

        <div v-if="type === 'farmer'" class="form-group">
          <label for="status">Status:</label> 
          <select id="status" v-model="user.status" class="form-select">
            <option value="pending">Pending</option>
            <option value="rejected">Rejected</option>
            <option value="approved">Approved</option>
          </select>
        </div>

        <div class="form-group">
          <label for="activity">Activity:</label>
          <select id="activity" v-model="user.activity" class="form-select">
            <option value="active">Active</option>
            <option value="disabled">Disabled</option>
          </select>
        </div>
        
        <div class="form-actions">
          <button type="submit" class="btn-submit">Update</button>
          <button type="button" @click="cancel" class="btn-cancel">Cancel</button>
        </div>
      </form>
    </div>
</template>
  
<script>
  import axios from 'axios';
  
  export default {
    props: ['id', 'type'],
    data() {
      return {
        user: {
          name: '',
          activity: '',
        },
      };
    },
    methods: {
      async fetchUser() {
        try {
          const response = await axios.get(
            `http://localhost:3003/api/users/${this.type}/${this.id}`
          );
          this.user = response.data;
        } catch (error) {
          console.error('Error fetching user:', error);
        }
      },
      async updateUser() {
        try {
          await axios.put(`http://localhost:3003/api/edit-user`, {
            userId: this.id,
            type: this.type,
            updates: this.user,
          });
          alert('User updated successfully!');
          this.$router.push('/management');
        } catch (error) {
          console.error('Error updating user:', error);
        }
      },
      cancel() {
        this.$router.push('/management'); 
      },
    },
    created() {
      this.fetchUser();
    },
  };
</script>
  
<style scoped>
  .edit-user-container {
    max-width: 600px;
    margin: 0 auto;
    padding: 20px;
    background-color: #fff;
    box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
    border-radius: 8px;
  }
  
  h1 {
    text-align: center;
    color: #333;
    font-size: 2em;
    margin-bottom: 20px;
  }
  
  .edit-user-form {
    display: flex;
    flex-direction: column;
    gap: 15px;
  }
  
  .form-group {
    display: flex;
    flex-direction: column;
  }
  
  label {
    font-size: 1em;
    margin-bottom: 5px;
    color: #333;
  }
  
  .form-input,
  .form-select {
    padding: 10px;
    font-size: 1em;
    border: 1px solid #ccc;
    border-radius: 5px;
    outline: none;
  }
  
  .form-input:focus,
  .form-select:focus {
    border-color: #007bff;
  }
  
  .form-actions {
    display: flex;
    gap: 10px;
    justify-content: center;
  }
  
  button {
    padding: 10px 20px;
    font-size: 1em;
    border: none;
    border-radius: 5px;
    cursor: pointer;
    width: 100%;
    max-width: 150px;
  }
  
  .btn-submit {
    background-color: #4caf50;
    color: white;
  }
  
  .btn-submit:hover {
    background-color: #45a049;
  }
  
  .btn-cancel {
    background-color: #f44336;
    color: white;
  }
  
  .btn-cancel:hover {
    background-color: #e53935;
  }
</style>  