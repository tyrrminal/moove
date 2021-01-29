<template>
  <b-container class="mt-3">
    <b-form @submit.prevent="uploadFile">
      <b-row>
        <b-col cols="2">
          <b-select
            v-model="type"
            :options="dataSources"
            value-field="id"
            text-field="name"
          >
          </b-select>
        </b-col>
        <b-col cols="5">
          <b-file
            accept="application/zip"
            v-model="upload"
            placeholder="Choose a file or drop it here..."
            drop-placeholder="Drop file here..."
          ></b-file>
        </b-col>
        <b-col cols="1">
          <b-button type="submit" :disabled="type == null || upload == null"
            >Submit</b-button
          >
        </b-col>
      </b-row>
    </b-form>
  </b-container>
</template>

<script>
import { mapGetters } from "vuex";

export default {
  name: "WorkoutEditor",
  data() {
    return {
      type: null,
      upload: null,
    };
  },
  computed: {
    ...mapGetters("meta", {
      getExternalDataSources: "getExternalDataSources",
      isLoaded: "isLoaded",
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
      this.$http.post("/activities/import", formData, {
        headers: { "Content-Type": "multipart/form-data" },
      });
    },
  },
};
</script>

<style scoped>
</style>