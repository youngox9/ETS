<template>
  <div
    :style="{
      display: 'flex',
      justifyContent: 'space-between',
      alignItems: 'flex-end',
      flexWrap: 'wrap',
      width: '100%',
      marginBottom: '12px',
    }"
  >
    <el-space v-if="list && list?.length && showPagination">
      <el-autocomplete
        class="page-size-select"
        type="number"
        v-model="pageConfig.pageSize"
        :fetch-suggestions="querySearchAsync"
        placeeholder=""
        size="small"
        @change="onPageSizeChange"
        @select="onPageSizeChange"
      >
        <template #prepend>每頁</template>
        <template #append>筆</template>
      </el-autocomplete>
      <el-pagination
        small
        background
        v-model:currentPage="pageConfig.page"
        v-model:page-size="pageConfig.pageSize"
        :page-count="pageConfig.total"
        :page-sizes="PAGE_SIZES"
        layout="prev, pager, next"
        @size-change="
          (val) => {
            onPageChange({ page: 1, pageSize: val });
          }
        "
        @current-change="
          (val) => {
            onPageChange({ page: val });
          }
        "
      />
    </el-space>
    <div v-else />

    <el-space :style="{ justifyContent: 'flex-end' }">
      <slot name="controls"></slot>
    </el-space>
  </div>

  <slot />

  <el-pagination
    v-if="list && list?.length && showPagination"
    small
    class="pagination-top"
    :style="{ justifyContent: 'flex-end', marginTop: '12px' }"
    background
    v-model:currentPage="pageConfig.page"
    v-model:page-size="pageConfig.pageSize"
    :page-count="pageConfig.total"
    :page-sizes="PAGE_SIZES"
    layout="prev, pager, next"
    @size-change="
      (val) => {
        onPageChange({ page: 1, pageSize: val });
      }
    "
    @current-change="
      (val) => {
        onPageChange({ page: val });
      }
    "
  />
</template>

<script setup>
import { defineExpose, nextTick, ref } from "vue";
import { useRoute, useRouter } from "vue-router";
import { useI18n } from "vue-i18n";
import { useState } from "@/utils";

const INITIAL_PAGECONFIG = { page: 1, total: 1, pageSize: 10 };
const PAGE_SIZES = [10, 100, 200, 300, 500, 1000];
const PAGE_SIZES_OPTIONS = PAGE_SIZES.map((val) => ({
  label: val,
  value: val,
  link: val,
}));
const props = defineProps({
  list: { type: Array, required: false },
  onChange: { type: Function, require: true },
  showPagination: { type: Boolean, require: false, default: true },
});

const { t } = useI18n();

const [pageConfig, setPageConfig] = useState(INITIAL_PAGECONFIG);

async function onPageChange(config) {
  const newConfig = { ...pageConfig.value, ...config };
  setPageConfig(newConfig);
  // console.log(">>>>", newConfig, ">>> old:", pageConfig.value);
  await nextTick();
  props.onChange(newConfig);
}

function onPageSizeChange(e) {
  console.log("change", pageConfig.value);
  props.onChange({ ...pageConfig.value });
}

const querySearchAsync = (queryString, cb) => {
  cb(PAGE_SIZES_OPTIONS);
};

async function reset() {
  setPageConfig(INITIAL_PAGECONFIG);
  // console.log(">>>>", newConfig, ">>> old:", pageConfig.value);
  await nextTick();
  props.onChange(INITIAL_PAGECONFIG);
}

defineExpose({
  pageConfig,
  setPageConfig: (config) => {
    setPageConfig({ ...pageConfig.value, ...config });
  },
  reset,
});
</script>

<style lang="scss">
.page-size-select {
  width: 90px;
  .el-input-group__prepend,
  .el-input-group__append {
    margin: 0;
    padding: 0 4px;
    border-radius: 0;
    font-size: 10px;
    display: flex;
    align-items: center;
    justify-content: center;
  }
  .el-input__inner {
    text-align: center;
    &::-webkit-outer-spin-button,
    &::-webkit-inner-spin-button {
      -webkit-appearance: none;
      margin: 0;
    }
  }
}
</style>
