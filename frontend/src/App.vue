<script setup lang="ts">
import NavBar from './components/ui/NavBar.vue';
import NoMetaMask from './components/ui/NoMetaMask.vue';
import NewMessage from './components/ui/NewMessage.vue';
import { storeToRefs } from "pinia";
import { useEtherStore } from "./stores/ether";
import { inject, onMounted } from 'vue'
const { connectWallet, setupNotifications } = useEtherStore();
const { account, canInteract } = storeToRefs(useEtherStore());

onMounted(() => {
  connectWallet(true);
  const toast = inject('toast');
  setupNotifications(toast);
})

</script>

<template>
  <div class="container mx-auto">
    <NavBar :wallet="account" @connectWallet="connectWallet" />
    <div class="flex justify-center pt-10">
      <div class="flex justify-center" v-if="!canInteract">
        <NoMetaMask />
      </div>
      <div class="flex justify-center" v-if="canInteract">
        <NewMessage />
      </div>
    </div>
  </div>
</template>
