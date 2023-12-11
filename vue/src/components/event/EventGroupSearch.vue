<template>
  <div>
    <b-tabs v-model="tab">
      <b-tab>
        <template #title>
          <b-icon icon="search" class="mr-2" />Search
        </template>
        <b-form @submit.prevent="doSearch" class="mt-2">
          <b-input-group>
            <b-input v-model="search" :name="'event-search-' + type" placeholder="Search..." />
            <template #append>
              <b-button type="submit" variant="success" @click="doSearch"><b-icon icon="search" /></b-button>
            </template>
          </b-input-group>
          <div v-if="results.length > 0">
            <hr class="my-2" />

            <b-button v-for="r in results " @click="selectEventGroup(r)"
              :variant="group == null || group.id != r.id ? 'outline-primary' : 'primary'" class="my-1" block size="sm">
              {{ r.name }}
            </b-button>

            <b-button pill variant="secondary" size="sm" block @click="toggleEditMode" :disabled="!group"><b-icon
                icon="pencil" class="mr-2" />Edit</b-button>
          </div>
        </b-form>

      </b-tab>
      <b-tab>
        <template #title>
          <b-icon icon="plus-circle" class="mr-2" />New
        </template>
      </b-tab>
    </b-tabs>

    <template v-if="editMode">
      <hr />
      <b-form @submit.prevent="saveEventGroup">
        <b-form-group label="Name" label-cols="2">
          <b-input name="event-group-name" v-model="group.name" />
        </b-form-group>
        <b-form-group label="URL" label-cols="2" description="Optional">
          <b-input type="url" name="event-group-url" v-model="group.url" />
        </b-form-group>
        <b-button pill variant="success" size="sm" block @click="saveEventGroup"><b-icon icon="upload"
            class="mr-2" />Save</b-button>
      </b-form>
    </template>
  </div>
</template>

<script>
export default {
  props: {
    type: {
      type: String,
      default: 'parent'
    },
    value: {
      required: true
    },
    current: {
      type: Object,
      required: false
    }
  },
  data: function () {
    return {
      group: null,

      tab: 0,
      editMode: false,
      search: "",
      results: []
    }
  },
  created: function () {
    this.group = { ...this.current }
  },
  methods: {
    doSearch: function () {
      this.group = { ...this.current };
      this.$http.get("eventgroups", { params: { type: this.type, name: this.search } })
        .then(resp => {
          this.results = resp.data
          if (this.group?.id && !this.results.find(x => x.id == this.group.id)) this.group = null
        })
    },
    toggleEditMode: function () {
      this.editMode = !this.editMode;
      if (this.editMode)
        this.$emit('input', null)
      else
        this.$emit('input', { ...this.group })
    },
    selectEventGroup: function (r) {
      this.group = { ...r }
      this.$emit('input', this.group)
    },
    saveEventGroup: function () {
      if (this.group == null) return;
      let p;
      if (this.group.id)
        p = this.$http.patch(`eventgroups/${this.group.id}`, this.group);
      else
        p = this.$http.post("eventgroups", this.group)
      p.then(resp => {
        this.selectEventGroup(resp.data)
        if (this.tab == 0) {
          this.doSearch();
          this.editMode = false
        }
      })
    }
  },
  watch: {
    tab: function (newValue, oldValue) {
      if (newValue == oldValue) return;
      if (newValue == 1) {
        this.editMode = true
        this.selectEventGroup({})
      } else {
        this.editMode = false;
        this.selectEventGroup({ ...this.current });
      }

    }
  }
}
</script>

<style></style>