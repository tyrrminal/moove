<template>
  <tfoot>
    <tr>
      <td v-for="c in options.columns" :key="c.key" :class="options.classes.tf">
        <slot :name="'foot(' + c.key + ')'" v-bind:column="c">
          <slot name="foot" v-bind:column="c">{{ c.title }}</slot>
        </slot>
      </td>
    </tr>
  </tfoot>
</template>

<script>
export default {
  name: "TreeTableFooter",
  props: {
    options: {
      type: Object,
      required: true,
    },
  },
};
</script>
