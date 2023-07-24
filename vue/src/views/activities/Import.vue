<template>
  <div>
    <b-container fluid>
      <b-row>
        <b-col cols="3" class="bg-light min-vh-100 mt-2">
          <b-form @submit.prevent="uploadFile">
            <b-form-group>
              <b-select v-model="type" :options="dataSources" value-field="id" text-field="name"
                :disabled="dataSources.length < 2">
              </b-select>
            </b-form-group>
            <b-form-group>
              <b-file accept="application/zip" v-model="upload" placeholder="Choose a file..."
                drop-placeholder="Drop file here..."></b-file>
            </b-form-group>
            <b-button type="submit" :disabled="type == null || upload == null || loading" block
              variant="primary">Submit</b-button>
          </b-form>
          <b-alert class="mt-2" v-for="(e, i) in errors" :key="i" variant="warning" :show="true">{{ e }}</b-alert>
        </b-col>

        <b-col v-if="loading" class="text-center mt-3">
          <b-spinner variant="primary" />
        </b-col>

        <b-col v-else-if="uploaded.length">
          <b-table small :fields="fields" :items="uploaded">
            <template #cell(startTime)="data">
              {{ data.value | luxon }}
            </template>
            <template #cell(activityType)="data">
              <b-link :to="{ name: 'activity', params: { id: data.item.id } }">{{
                activityType(data.item.activityTypeID).description }}</b-link>
            </template>
            <template #cell(isNew)="data">
              <b-badge v-if="data.value" variant="success">NEW!</b-badge>
              <b-badge v-else variant="secondary">Imported</b-badge>
            </template>
          </b-table>
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

      fields: [
        {
          key: 'startTime'
        },
        {
          key: 'activityType',
          label: 'Activity'
        },
        {
          key: 'isNew',
          label: ""
        }
      ],

      uploaded: [],
      loading: false,
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
    compareActivities: function (a, b) {
      if (a.isNew && !b.isNew) return -1;
      if (!a.isNew && b.isNew) return 1;
      return a.startTime.localeCompare(b.startTime)
    },
    uploadFile: function () {
      const formData = new FormData();
      formData.append("file", this.upload, this.upload.name);
      formData.append("externalDataSourceID", this.type);
      this.loading = true
      this.$http
        .post("/activities/import", formData, {
          headers: { "Content-Type": "multipart/form-data" },
        })
        .then((resp) => {
          this.errors = [];
          let uploaded = resp.data.map(a => ({ ...a, ...a.sets[0] }));
          this.uploaded.push(...uploaded);
          uploaded.sort((a, b) => this.compareActivities(a, b));
          this.loading = false
          this.upload = null
        })
        .catch(err => {
          this.errors = [];
          err.response.data.errors.forEach(e => this.errors.push(e.message))
        });
    },
  },
  watch: {
    dataSources: {
      immediate: true,
      handler: function (newValue) {
        if (this.type == null && newValue.length > 0) this.type = newValue[0].id
      }
    }
  }
};
</script>

<style scoped></style>
