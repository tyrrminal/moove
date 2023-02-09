<template>
  <b-row>
    <b-col>
      <b-form-select :value="perPage" :options="options" @input="updatePerPage" :size="size"
        :style="{ maxWidth: '5em' }" class="float-left mr-3"></b-form-select>
      <b-pagination :value="currentPage" :total-rows="totalRows" :per-page="perPage" @input="updateCurrentPage"
        :size="size">
      </b-pagination>
    </b-col>
    <b-col class="text-right">
      <span>
        <em>
          <template v-if="startItem < endItem">Items {{ startItem }} -</template>
          <template v-else>Item</template>
          {{ endItem }} of {{ totalRows }}
          <template v-if="totalResults != null && totalResults !== totalRows">({{ totalResults }} total)</template>
        </em>
      </span>
    </b-col>
  </b-row>
</template>

<script>
export default {
  name: "DetailedPagination",
  props: {
    size: {
      type: String,
      default: "md"
    },
    perPage: {
      type: Number
    },
    currentPage: {
      type: Number
    },
    totalRows: {
      type: Number
    },
    totalResults: {
      type: Number
    },
    options: {
      type: Array,
      default: function () {
        return [5, 10, 25, 50];
      }
    }
  },
  computed: {
    startItem: function () {
      return (this.currentPage - 1) * this.perPage + 1;
    },
    endItem: function () {
      return Math.min(this.startItem + this.perPage - 1, this.totalRows);
    }
  },
  methods: {
    updatePerPage: function (value) {
      this.$emit("update:perPage", value);
    },
    updateCurrentPage: function (value) {
      this.$emit("update:currentPage", value);
    }
  }
};
</script>

<style>

</style>