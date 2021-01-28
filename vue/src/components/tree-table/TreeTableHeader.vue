<template>
  <thead>
    <tr>
      <th v-for="c in options.columns" :key="c.key" :class="options.classes.th">
        <slot :name="'head(' + c.key + ')'" v-bind:column="c"
          ><slot name="head" v-bind:column="c">{{ c.title }}</slot></slot
        >
      </th>
    </tr>
  </thead>
</template>

<script>
export default {
  name: "TreeTableHeader",
  props: {
    options: {
      type: Object,
      required: true,
    },
  },
};
</script>
