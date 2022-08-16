<template>
  <div>
    <b-container class="mt-3">
      <b-form @submit.prevent="uploadFile">
        <b-row>
          <b-col cols="2">
            <b-select v-model="type" :options="dataSources" value-field="id" text-field="name">
            </b-select>
          </b-col>
          <b-col cols="5">
            <b-file accept="application/zip" v-model="upload" placeholder="Choose a file or drop it here..."
              drop-placeholder="Drop file here..."></b-file>
          </b-col>
          <b-col cols="1">
            <b-button type="submit" :disabled="type == null || upload == null">Submit</b-button>
          </b-col>
        </b-row>
      </b-form>
      <b-alert class="mt-2" v-for="(e, i) in errors" :key="i" variant="warning" :show="true">{{ e }}</b-alert>
    </b-container>


    <b-container v-if="uploaded.length > 0" class="mt-3">
      <b-row v-for="activity in uploaded.filter((a) => a.isNew)" :key="activity.id">
        <b-col>
          <b-link :to="{ name: 'activity', params: { id: activity.id } }">{{
              activityType(activity.activityTypeID).description
          }}</b-link>
          on
          {{ activity.startTime | luxon
          }}<b-badge class="ml-2" variant="success">NEW!</b-badge>
        </b-col>
      </b-row>
      <b-row v-for="activity in uploaded.filter((a) => !a.isNew)" :key="activity.id">
        <b-col class="text-muted">
          <b-link :to="{ name: 'activity', params: { id: activity.id } }">{{
              activityType(activity.activityTypeID).description
          }}</b-link>
          on
          {{ activity.startTime | luxon }}
        </b-col>
      </b-row>
    </b-container>
  </div>
</template>

<script>
import { mapGetters } from "vuex";

export default {
  name: "WorkoutEditor",
  data() {
    return {
      type: null,
      upload: null,

      uploaded: [],
      errors: [],
    };
  },
  computed: {
    ...mapGetters("meta", {
      getExternalDataSources: "getExternalDataSources",
      isLoaded: "isLoaded",
      activityType: "getActivityType",
    }),
    dataSources: function () {
      return this.getExternalDataSources.filter((ds) => ds.type == "Activity");
    },
  },
  methods: {
    uploadFile: function () {
      const formData = new FormData();
      formData.append("file", this.upload, this.upload.name);
      formData.append("externalDataSourceID", this.type);
      this.$http
        .post("/activities/import", formData, {
          headers: { "Content-Type": "multipart/form-data" },
        })
        .then((resp) => {
          this.errors = [];
          let uploaded = resp.data.map(a => ({ ...a, ...a.sets[0] }));
          uploaded.sort((a, b) => a.startTime.localeCompare(b.startTime));
          this.uploaded.push(...uploaded);
        })
        .catch(err => {
          this.errors = [];
          err.response.data.errors.forEach(e => this.errors.push(e.message))
        });
    },
  },
};
</script>

<style scoped>
</style>