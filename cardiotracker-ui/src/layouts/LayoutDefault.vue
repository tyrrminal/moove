<template>
  <div>
    <slot name="sidebar" />
    <b-container>
      <b-row>
        <b-col class="mt-2">
          <slot />
        </b-col>
      </b-row>
    </b-container>
  </div>
</template>

<script>
export default {};
</script>
