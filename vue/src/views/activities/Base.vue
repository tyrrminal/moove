<template>
  <div class="mt-1">
    <b-button-group>
      <b-dropdown text="Cardio"
        ><b-dropdown-item v-for="i in cardioTypes" :key="i.id">{{
          i.description
        }}</b-dropdown-item></b-dropdown
      >
      <b-dropdown text="Lifts"
        ><b-dropdown-item v-for="i in liftTypes" :key="i.id">{{
          i.description
        }}</b-dropdown-item></b-dropdown
      >
      <b-dropdown text="Holds"
        ><b-dropdown-item v-for="i in holdTypes" :key="i.id">{{
          i.description
        }}</b-dropdown-item></b-dropdown
      >
    </b-button-group>
    <router-view></router-view>
  </div>
</template>

<script>
export default {
  data: function () {
    return {
      iconScale: 1.5,
    };
  },
  computed: {
    cardioTypes: function () {
      return [];
    },
    liftTypes: function () {
      return [];
    },
    holdTypes: function () {
      return [];
    },
  },
};
</script>

<style>
</style>