<template>
  <b-card title="Personal Records" class="records">
    <List :records="records" :flush="true" />
  </b-card>
</template>

<script>
import List from "@/components/activity/lists/Records.vue";

export default {
  components: {
    List
  },
  props: {
    records: Array
  }
};
</script>
