<template>
  <b-jumbotron class="p-2" bg-variant="white">
    <strong class="smart-quotes pr-2">&ldquo;</strong>
    <em>
      <slot></slot>
    </em>
    <strong class="smart-quotes pl-2">&rdquo;</strong>
  </b-jumbotron>
</template>

<script>
export default {

}
</script>

<style>
.smart-quotes {
  font-size: 18pt;
  font-family: 'Times New Roman', Times, serif;
}
</style>