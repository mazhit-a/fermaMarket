<template>
  <div class="admin-dashboard">
    <h1>Admin Dashboard</h1>

    <div class="user-columns">
      <section class="user-section">
        <h2>Farmers</h2>
        <div v-if="farmers.length === 0" class="empty-message">No Farmers Found</div>
        <div v-for="farmer in sortedFarmers" :key="farmer.farmerid" class="user-card">
          <div class="user-info">
            <p><strong>ID:</strong> {{ farmer.farmerid }}</p>
            <p><strong>Name:</strong> {{ farmer.name }}</p>
            <p><strong>Activity:</strong> {{ farmer.activity }}</p>
          </div>
          <div class="button-group">
            <button @click="toggleUserStatus(farmer.farmerid, 'farmer', farmer.activity !== 'active')" class="toggle-button">
              {{ farmer.activity === 'active' ? 'Disable' : 'Enable' }}
            </button>
            <button @click="editUser(farmer.farmerid, 'farmer')" class="edit-button">View all information and edit</button>
            <button @click="deleteUser(farmer.farmerid, 'farmer')" class="delete-button">Delete</button>
          </div>
        </div>
      </section>


      <section class="user-section">
        <h2>Buyers</h2>
        <div v-if="buyers.length === 0" class="empty-message">No Buyers Found</div>
        <div v-for="buyer in sortedBuyers" :key="buyer.buyerid" class="user-card">
          <div class="user-info">
            <p><strong>ID:</strong> {{ buyer.buyerid }}</p>
            <p><strong>Name:</strong> {{ buyer.name }}</p>
            <p><strong>Activity:</strong> {{ buyer.activity }}</p>
          </div>
          <div class="button-group">
            <button @click="toggleUserStatus(buyer.buyerid, 'buyer', buyer.activity !== 'active')" class="toggle-button">
              {{ buyer.activity === 'active' ? 'Disable' : 'Enable' }}
            </button>
            <button @click="editUser(buyer.buyerid, 'buyer')" class="edit-button">View all information and edit</button>
            <button @click="deleteUser(buyer.buyerid, 'buyer')" class="delete-button">Delete</button>
          </div>
        </div>
      </section>
    </div>
  </div>
</template>

<script>
import axios from 'axios';
axios.defaults.withCredentials = true;

export default {
  data() {
    return {
      farmers: [],
      buyers: [],
    };
  },
  computed: {
    sortedFarmers() {
      return [...this.farmers].sort((a, b) => a.farmerid - b.farmerid);
    },
    sortedBuyers() {
      return [...this.buyers].sort((a, b) => a.buyerid - b.buyerid);
    },
  },
  methods: {
    async fetchUsers() {
      try {
        const response = await axios.get('http://localhost:3003/api/users', { withCredentials: true });
        this.farmers = response.data.farmers;
        this.buyers = response.data.buyers;
      } catch (error) {
        if (error.response && error.response.status === 403) {
          alert('You must be logged in to access this page.');
          this.$router.push('/login');
        }
        console.error('Error fetching users:', error);
      }
    },
    async toggleUserStatus(userId, type, enable) {
      try {
        await axios.post('http://localhost:3003/api/toggle-user-status', {userId, type, enable}, { withCredentials: true });
        this.fetchUsers();
      } catch (error) {
        console.error('Error toggling user status:', error);
      }
    },
    async editUser(userId, type) {
      this.$router.push(`/edit-user/${type}/${userId}`);
    },

    async deleteUser(userId, type) {
      if (confirm('Are you sure you want to delete this user?')) {
        try {
          await axios.delete('http://localhost:3003/api/delete-user', {data: { userId, type }}, { withCredentials: true });
          this.fetchUsers();
        } catch (error) {
          console.error('Error deleting user:', error);
        }
      }
    },
  },
  created() {
    this.fetchUsers();
  },
};
</script>

<style scoped>
.admin-dashboard {
  max-width: 1200px;
  margin: 20px auto;
  font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
  padding: 20px;
}

h1 {
  text-align: center;
  font-size: 2.2rem;
  color: #444;
  margin-bottom: 30px;
}

.user-columns {
  display: flex;
  justify-content: space-between;
  gap: 20px;
}

.user-section {
  flex: 1;
}

h2 {
  color: #333;
  font-size: 1.5rem;
  border-bottom: 2px solid #ddd;
  padding-bottom: 8px;
  margin-bottom: 20px;
}

.user-card {
  border-radius: 8px;
  background-color: #ffffff;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
  padding: 20px;
  margin-bottom: 15px;
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.user-info p {
  margin: 5px 0;
  color: #555;
  font-size: 1rem; 
}

.button-group {
  display: flex;
  gap: 12px;
  justify-content: space-between;
}

button {
  padding: 10px 15px;
  font-size: 14px;
  border-radius: 6px;
  cursor: pointer;
  border: none;
  outline: none;
  transition: transform 0.2s;
}

button:hover {
  opacity: 0.9;
  transform: scale(1.05);
}

.toggle-button {
  background-color: #8e8e8e;
  color: white;
}

.edit-button {
  background-color: #ff9800;
  color: white;
}

.delete-button {
  background-color: #f44336;
  color: white;
}

.empty-message {
  text-align: center;
  color: #999;
  font-style: italic;
  font-size: 1rem;
}


@media (max-width: 768px) {
  .admin-dashboard {
    padding: 10px;
  }

  h1 {
    font-size: 1.8rem; 
  }

  .user-columns {
    flex-direction: column; 
    gap: 20px;
  }

  h2 {
    font-size: 1.3rem;
    margin-bottom: 15px;
  }

  .user-card {
    padding: 15px;
    margin-bottom: 10px;
  }

  .user-info p {
    font-size: 0.9rem; 
  }

  .button-group {
    flex-wrap: wrap; 
    gap: 10px;
  }

  button {
    flex: 1;
    padding: 8px 10px;
    font-size: 13px; 
  }
}
</style>
