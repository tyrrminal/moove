<template>
  <thead>
    <tr>
      <th v-for="c in options.columns" :key="c.key" :class="options.classes.th">
        <slot :name="'head(' + c.key + ')'" v-bind:column="c" v-bind:sort="options.sort">
          <slot name="head" v-bind:column="c" v-bind:sort="options.sort">{{ c.title }}
            <b-button v-if="options.sortable" size="sm" variant="outline" @click="$emit('update:sort', c)">
              <b-icon v-if="
                options.sort.field == c.key ||
                options.sort.field == c['sort-key']
              " :icon="
  options.sort.direction == 'desc'
    ? 'caret-down-fill'
    : 'caret-up-fill'
" />
              <b-iconstack v-else>
                <b-icon variant="secondary" icon="caret-up-fill" scale="0.5" shift-v="4" />
                <b-icon variant="secondary" icon="caret-down-fill" scale="0.5" shift-v="-4" /> </b-iconstack></b-button>
          </slot>
        </slot>
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
