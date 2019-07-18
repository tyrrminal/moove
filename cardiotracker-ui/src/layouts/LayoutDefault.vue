<template>
  <b-container fluid>
    <b-row>
      <b-col sm="2">
        <slot name="sidebar" />
      </b-col>
      <b-col sm="10" class="mt-2">
        <slot />
      </b-col>
    </b-row>
  </b-container>
</template>

<script>
export default {

}
</script>
