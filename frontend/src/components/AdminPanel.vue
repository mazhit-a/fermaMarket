<template>
  <div class="admin-panel">
    <h2>Pending Farmers</h2>
    <div v-if="farmers.length === 0" class="no-farmers">
      <p>No pending farmers to approve or reject.</p>
    </div>
    <div v-else>
      <div v-for="farmer in farmers" :key="farmer.farmerid" class="farmer-card">
        <h3>{{ farmer.farmer_name }}</h3>
        <p><strong>Email:</strong> {{ farmer.email }}</p>
        <p><strong>Phone:</strong> {{ farmer.phone_number }}</p>
        <p><strong>Location:</strong> {{ farmer.location }}</p>
        <div class="button-group">
          <button @click="approveFarmer(farmer.farmerid)" class="approve-button">Approve</button>
          <button @click="rejectFarmer(farmer.farmerid)" class="reject-button">Reject</button>
        </div>
      </div>
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
    };
  },
  methods: {
    async fetchFarmers() {
      try {
        const response = await axios.get('http://localhost:3003/api/pending-farmers', { withCredentials: true });
        if (response.data.data) {
          this.farmers = response.data.data;
        }
      } catch (error) {
        if (error.response && error.response.status === 403) {
          alert('You must be logged in to access this page.');
          this.$router.push({ name: 'Login' });
        }
        console.error('Error fetching farmers:', error);
      }
    },
    async approveFarmer(farmerId) {
      try {
        const response = await axios.post('http://localhost:3003/api/approve-farmer', {farmerid: farmerId}, { withCredentials: true });
        if (response.data && response.data.message === 'Farmer approved successfully') {
          this.farmers = this.farmers.filter(farmer => farmer.farmerid !== farmerId);
          alert('Farmer approved successfully!');
        } else {
          throw new Error('Unexpected response from server');
        }
      } catch (error) {
        console.error('Error approving farmer:', error.response ? error.response.data : error.message);
        alert('Failed to approve farmer');
      }
    },
    async rejectFarmer(farmerId) {
      const reason = prompt('Please provide a reason for rejection:');
      if (!reason) {
        return;
      }
      try {
        await axios.post('http://localhost:3003/api/reject-farmer', { farmerId, reason }, { withCredentials: true });
        this.fetchFarmers();
        alert('Farmer rejected successfully');
      } catch (error) {
        console.error('Error rejecting farmer:', error);
        alert('Error rejecting farmer');
      }
    },
  },
  created() {
    this.fetchFarmers();
  },
};
</script>

<style scoped>
.admin-panel {
  max-width: 600px;
  margin: auto;
  font-family: Arial, sans-serif;
}

h2 {
  text-align: center;
  color: #333;
}

.no-farmers {
  text-align: center;
  color: #888;
}

.farmer-card {
  border: 1px solid #ddd;
  border-radius: 8px;
  padding: 16px;
  margin: 12px 0;
  background-color: #f9f9f9;
  box-shadow: 0 2px 5px rgba(0, 0, 0, 0.1);
}

.farmer-card h3 {
  margin-top: 0;
  color: #444;
}

.button-group {
  display: flex;
  justify-content: flex-start;
}

button {
  padding: 8px 12px;
  border: none;
  border-radius: 4px;
  font-size: 14px;
  cursor: pointer;
  transition: transform 0.2s;
}

button:hover {
  opacity: 0.9;
  transform: scale(1.05);
}

.approve-button {
  background-color: #4CAF50;
  color: white;
  margin-right: 8px;
}

.reject-button {
  background-color: #f44336;
  color: white;
}
</style>
