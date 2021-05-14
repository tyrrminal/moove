<template>
  <b-modal
    id="addDonation"
    title="Add Donation"
    @show="onShow"
    @ok="save"
    no-close-on-backdrop
  >
    <b-breadcrumb>
      <b-breadcrumb-item
        text="Donor"
        @click="clearDonor"
        :active="stageDonor"
      />
      <b-breadcrumb-item
        text="Address"
        @click="clearAddress"
        :active="stageAddress"
        v-if="stageAddress || stageAmount"
      />
      <b-breadcrumb-item
        text="Amount"
        v-if="stageAmount"
        :active="stageAmount"
      />
    </b-breadcrumb>
    <template v-if="stageDonor">
      <b-form inline @submit.prevent="searchDonors">
        <b-form-group label="Firstname" class="mr-2">
          <b-input v-model="search.firstname" size="sm" />
        </b-form-group>
        <b-form-group label="Lastname" class="mr-2">
          <b-input v-model="search.lastname" size="sm" />
        </b-form-group>
        <b-button type="submit" variant="primary" size="sm" class="mt-4"
          >Search</b-button
        >
      </b-form>
      <template v-if="results.donors">
        <hr />
        <template v-if="results.donors.length">
          <b-form-group label="Donors">
            <b-input-group>
              <b-select :options="donorSearchResults" v-model="preselect.donor">
              </b-select>
              <template #append>
                <b-button
                  @click="selectDonor"
                  :disabled="preselect.donor == null"
                  variant="success"
                  >Select</b-button
                >
              </template>
            </b-input-group>
          </b-form-group>
          <div class="text-center">or</div>
        </template>
        <h4 class="text-center" v-else>No results</h4>
        <b-row align-h="center">
          <b-button
            :disabled="!fullName"
            class="mt-1"
            size="sm"
            variant="success"
            @click="createNewDonor"
            >Create New</b-button
          >
        </b-row>
      </template>
    </template>
    <template v-else-if="stageAddress">
      <b-row>
        <b-col>
          <b-form-group label="Firstname" label-size="sm">
            <b-input
              :disabled="true"
              v-model="selected.person.firstname"
              size="sm"
            />
          </b-form-group>
        </b-col>
        <b-col>
          <b-form-group label="Lastname" label-size="sm">
            <b-input
              :disabled="true"
              v-model="selected.person.lastname"
              size="sm"
            />
          </b-form-group>
        </b-col>
      </b-row>
      <b-row v-if="results.addresses.length > 0">
        <b-col>
          <b-input-group>
            <b-select :options="donorAddresses" v-model="preselect.address" />
            <template #append>
              <b-button
                variant="success"
                :disabled="preselect.address == null"
                @click="selectAddress"
                >Select</b-button
              >
            </template>
          </b-input-group>
        </b-col>
      </b-row>
      <div class="text-center">or</div>
      <b-row>
        <b-col>
          <b-form-group label="Street 1">
            <b-input v-model="preselect.newAddress.street1" />
          </b-form-group>
        </b-col>
        <b-col>
          <b-form-group label="Street 2">
            <b-input v-model="preselect.newAddress.street2" />
          </b-form-group>
        </b-col>
      </b-row>
      <b-row>
        <b-col cols="6">
          <b-form-group label="City">
            <b-input v-model="preselect.newAddress.city" />
          </b-form-group>
        </b-col>
        <b-col cols="2">
          <b-form-group label="State">
            <b-input v-model="preselect.newAddress.state" />
          </b-form-group>
        </b-col>
        <b-col>
          <b-form-group label="Zip">
            <b-input v-model="preselect.newAddress.zip" />
          </b-form-group>
        </b-col>
      </b-row>
      <b-row>
        <b-col cols="4">
          <b-form-group label="Phone #">
            <b-input v-model="preselect.newAddress.phone" />
          </b-form-group>
        </b-col>
        <b-col>
          <b-form-group label="Email Address">
            <b-input v-model="preselect.newAddress.email" />
          </b-form-group>
        </b-col>
      </b-row>
      <b-row align-h="center">
        <b-button variant="success" @click="createNewAddress" size="sm"
          >Create New</b-button
        >
      </b-row>
    </template>
    <template v-else-if="stageAmount">
      <b-form-group label="Donor">
        <b-input
          :value="`${selected.person.firstname} ${selected.person.lastname}`"
          :disabled="true"
        />
      </b-form-group>
      <b-form-group label="Address">
        <b-input
          :value="$options.filters.formatAddress(selected.address)"
          :disabled="true"
        ></b-input>
      </b-form-group>

      <b-form-group label="Date">
        <b-datepicker v-model="selected.date" />
      </b-form-group>
      <b-form-group label="Amount">
        <b-input-group prepend="$">
          <b-input v-model="selected.amount" />
        </b-input-group>
      </b-form-group>
    </template>
  </b-modal>
</template>

<script>
import { DateTime } from "luxon";
import EventFilters from "@/mixins/events/Filters.js";

export default {
  mixins: [EventFilters],
  props: {
    userEventActivityID: {
      type: Number,
      required: true,
    },
  },
  data: function () {
    return {
      search: {
        firstname: "",
        lastname: "",
        results: null,
      },
      results: {
        donors: null,
        addresses: null,
      },
      preselect: {
        donor: null,
        address: null,
        newAddress: {
          street1: null,
          street2: null,
          city: null,
          state: null,
          country: null,
          zip: null,
          phone: null,
          email: null,
        },
      },
      selected: {
        person: null,
        address: null,
        date: null,
        amount: null,
      },
    };
  },
  methods: {
    save: function (bvModalEvent) {
      this.$http
        .post(
          ["user", "events", this.userEventActivityID, "donations"].join("/"),
          this.selected
        )
        .then((resp) => {
          this.$root.$emit("bv::hide::modal", "addDonation");
          this.$emit("update", resp.data);
        });
      bvModalEvent.preventDefault();
    },
    onShow: function () {
      this.search = { firstname: "", lastname: "" };
      this.results = { donors: null, addresses: null };
      this.preselect = {
        donor: null,
        newAddress: {
          street1: null,
          street2: null,
          city: null,
          state: null,
          country: null,
          zip: null,
          phone: null,
          email: null,
        },
      };
      this.selected = {
        person: null,
        address: null,
        date: DateTime.local().toISODate(),
        amount: null,
      };
    },
    searchDonors: function () {
      let q = {};
      ["firstname", "lastname"].forEach((x) => {
        if (this.search[x]) q[x] = this.search[x];
      });
      this.$http
        .get("donors", {
          params: q,
        })
        .then(
          (resp) =>
            (this.results.donors = resp.data.map((x) => ({
              ...x.person,
              addresses: x.addresses,
            })))
        );
    },
    clearAddress: function () {
      this.selected.address = null;
    },
    clearDonor: function () {
      this.selected.person = null;
    },
    selectDonor: function () {
      this.selected.person = {
        ...this.results.donors.find((x) => x.id == this.preselect.donor),
      };
      this.results.addresses = this.selected.person.addresses;
      delete this.selected.person.addresses;
    },
    createNewDonor: function () {
      this.selected.person = {
        firstname: this.search.firstname,
        lastname: this.search.lastname,
      };
      this.results.addresses = [];
    },
    selectAddress: function () {
      this.selected.address = this.results.addresses.find(
        (x) => x.id == this.preselect.address
      );
    },
    createNewAddress: function () {
      this.selected.address = this.preselect.newAddress;
    },
  },
  computed: {
    stageDonor: function () {
      return this.selected.person == null;
    },
    stageAddress: function () {
      return this.selected.person != null && this.selected.address == null;
    },
    stageAmount: function () {
      return this.selected.person != null && this.selected.address != null;
    },

    donorSearchResults: function () {
      return this.results.donors.map((x) => ({
        ...x,
        text: `${x.firstname} ${x.lastname}`,
        value: x.id,
      }));
    },
    donorAddresses: function () {
      let self = this;
      return this.results.addresses.map((x) => ({
        ...x,
        text: self.$options.filters.formatAddress(x),
        value: x.id,
      }));
    },
    donorSelected: function () {
      return this.selected.person != null;
    },
    addressSelected: function () {
      return this.selected.address != null;
    },
    fullName: function () {
      return (
        this.search.firstname.length > 1 && this.search.lastname.length > 1
      );
    },
  },
};
</script>

<style scoped>
</style>