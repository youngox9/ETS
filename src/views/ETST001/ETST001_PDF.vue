<template>
  <div class="doc-container">
    <PrinterHeader :title="'員工訓練履歷表'" />
    <!-- etsb -->
    <ETST001_Table :data="data" />
    <p>MA-QR-028-01</p>
  </div>
</template>

<script setup>
import _ from "lodash";
import { useStore } from "vuex";
import { computed, onMounted } from "vue";
import { useRoute, useRouter } from "vue-router";
import { useI18n } from "vue-i18n";
import { useState, printPage } from "@/utils";

import PrinterHeader from "@/components/Printer/PrinterHeader.vue";
import ETST001_Table from "./ETST001_Table.vue";

const props = defineProps([]);
const { t } = useI18n();
const store = useStore();
const router = useRouter();
const route = useRoute();

const [data, setData] = useState(window.data || {});

onMounted(() => {
  setTimeout(() => {
    printPage();
  }, 1000);
});
</script>

<style lang="scss" scoped>
.doc-container {
  display: block;
  width: 1600px;
  max-width: 100%;
  margin: 0 auto;
  position: relative;
  padding-bottom: 64px;
}
</style>
