<template>
  <div id="nav">
    <router-link to="/">Home</router-link> |
    <router-link :to="{ name: 'legacy_summary' }">Summary</router-link> |
    <router-link :to="{ name: 'legacy_events' }">Events</router-link> |
    <UserStatus />
  </div>
</template>

<script>
import UserStatus from '@/components/UserStatus.vue';

export default {
  components: {
    UserStatus
  },
}
</script>

<style>

</style>
