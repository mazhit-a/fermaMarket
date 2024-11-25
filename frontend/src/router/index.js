// src/router/index.js
import { createRouter, createWebHistory } from 'vue-router';
import HomePage from '../components/HomePage.vue';
import Register from '../components/AdminRegistration.vue';
import Login from '../components/AdminAuthorization.vue';
import Panel from '../components/AdminPanel.vue';
import ForgotPassword from '../components/ForgotPassword.vue';
import ResetPassword from '../components/ResetPassword.vue';
import UserManagement from '@/components/UserManagement.vue';
import EditUser from '@/components/EditUser.vue';

const routes = [
  {
    path: '/',
    name: 'Home', // Route name should match exactly
    component: HomePage,
  },
  {
    path: '/register',
    name: 'Register',
    component: Register,
  },
  {
    path: '/login',
    name: 'Login',
    component: Login,
  },
  {
    
    path: '/panel',
    name: 'Panel',
    component: Panel,
  },
  { path: '/forgot-password', 
    name: 'ForgotPassword', 
    component: ForgotPassword 
  },
  { 
    path: '/reset-password/:token', 
    name: 'ResetPassword', 
    component: ResetPassword 
  },
  {
    path: '/management',
    name: 'UserManagement',
    component: UserManagement
  },
  { 
    path: '/edit-user/:type/:id',
    name: 'EditUser',
    component: EditUser, 
    props: true
  },
];

const router = createRouter({
  history: createWebHistory(),
  routes,
});

export default router;
