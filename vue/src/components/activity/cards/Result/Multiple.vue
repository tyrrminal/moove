<template>
  <b-table :items="sets" :fields="fields">
    <template #cell(startTime)="data">
      {{ data.value | luxon({ output: "short" }) }}
    </template>
    <template #cell(actions)="data">
      <b-dropdown size="sm" variant="outline-secondary">
        <template #button-content>
          <b-icon icon="gear" />
        </template>
        <b-dropdown-item :to="{
          name: 'edit-activity',
          params: { activity: { ...activity, ...data.item } },
        }">
          <b-icon icon="pencil" class="mr-1" />Edit
        </b-dropdown-item>
        <b-dropdown-item @click="deleteSet(data.item.id)">
          <b-icon icon="trash" variant="danger" class="mr-1" />Delete
        </b-dropdown-item>
      </b-dropdown>
    </template>
  </b-table>
</template>

<script>
export default {
  props: {
    activity: {
      type: Object,
      required: true,
    },
    editable: {
      type: Boolean,
      default: true,
    },
  },
  computed: {
    sets: function () {
      return [...this.activity.sets].sort((a, b) =>
        a.startTime.localeCompare(b.startTime)
      );
    },
    fields: function () {
      let f = [{ key: "startTime" }];
      if (this.sets.some((s) => Object.hasOwn(s, "distance")))
        f.push({ key: "distance" });
      if (this.sets.some((s) => Object.hasOwn(s, "duration")))
        f.push({ key: "duration" });
      if (this.sets.some((s) => Object.hasOwn(s, "netTime")))
        f.push({ key: "netTime" });
      if (this.sets.some((s) => Object.hasOwn(s, "pace")))
        f.push({ key: "pace" });
      if (this.sets.some((s) => Object.hasOwn(s, "speed")))
        f.push({ key: "speed" });
      if (this.sets.some((s) => Object.hasOwn(s, "repetitions")))
        f.push({ key: "repetitions", label: "# Reps" });
      if (this.sets.some((s) => Object.hasOwn(s, "weight")))
        f.push({ key: "weight" });
      if (this.editable) f.push({ key: "actions", label: "" });
      return f;
    },
  },
  methods: {
    deleteSet: function (id) {
      this.$bvModal
        .msgBoxConfirm("This activity set will be permanently deleted.", {
          okButton: "delete",
          okVariant: "danger",
        })
        .then((value) => {
          if (value) {
            this.$http
              .delete(["activities", id].join("/"), {
                headers: { Accept: "text/plain" },
              })
              .then((resp) => {
                this.activity.sets.splice(
                  this.activity.sets.findIndex((s) => s.id == id),
                  1
                );
              });
          }
        });
    },
  },
};
</script>

<style scoped>

</style>
