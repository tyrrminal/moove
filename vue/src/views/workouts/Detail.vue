<template>
  <b-container class="mt-3">
    <h4 class="float-right">{{ entity.date | luxon }}</h4>
    <h3>{{ entity.name }}</h3>

    <b-card no-body>
      <template #header>
        Activities
      </template>
      <b-card-body>
        <div v-if="entity.activities.length"></div>
        <b-link :to="{ name: 'edit-activity' }">
          <b-icon icon="plus" class="mr-1" />Add an Activity
        </b-link>
      </b-card-body>
    </b-card>
  </b-container>
</template>

<script>
export default {
  data: function () {
    return {
      id: this.$attrs.id,
      entity: null,
    };
  },
  mounted() {
    this.getData();
  },
  methods: {
    getData: function () {
      this.$http.get(["workouts", this.id].join("/")).then(resp => this.entity = resp.data);
    },
  },
};
</script>

<style>
</style>