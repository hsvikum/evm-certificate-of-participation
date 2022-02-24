<template>
  <div class="card w-auto bg-primary text-primary-content">
    <div class="card-body" v-if="!minted">
      <h2 class="card-title">What is your name ?</h2>
      <p>Congratulation for sticking till the end 🥳🎉.<br/>Please note you can mint one certificate per address.</p>
      <div>
        <input type="text"
          v-model="message"
          class="input input-bordered input-primary w-full"
          placeholder="Name is optional.Also No special characters allowed."
        />
      </div>
      <div class="justify-end card-actions">
        <button
          class="btn"
          @click="submit"
          :class="{ 'btn-disabled': !submittable }"
        >
          Mint My Certificate
        </button>
      </div>
    </div>

    <div class="card-body" v-if="minted">
      <h2 class="card-title">Looks like you have minted your certificate already 🎉</h2>
      <p>Go to OpenSea and checkout your shiny new certificate</p>
      <div class="justify-end card-actions">
        <button
          class="btn"
          @click="gotoOpenSea"
        >
          Take me to OpenSea ⛵
        </button>
      </div>
    </div>
  </div>
</template>

<script lang="ts" setup>
import { computed } from "vue";

import { storeToRefs } from "pinia";
import { useEtherStore } from "../../stores/ether";
const { message, loading, minted } = storeToRefs(useEtherStore());
const { mintCertificate } = useEtherStore();

const submittable = computed(() => {
  return message.value.length <= 100 && (/^[A-Za-z0-9\s]+$/.test(message.value) || message.value == '') && !loading.value;
});

const submit = async () => {
  if (submittable.value) {
    mintCertificate();
  }
};

const gotoOpenSea = () => {
   window.open('https://testnets.opensea.io/account', '_blank')
};
</script>
