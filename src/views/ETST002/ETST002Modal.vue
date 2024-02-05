<template>
  <el-dialog
    v-model="$attrs.modelValue.isOpen"
    :title="`${$attrs?.modelValue.mode === 'add' ? $t('add') : $t('edit')} ${$t(
      'title_ETST002'
    )}`"
  >
    {{ $attrs?.modelValue?.isOpen }}
    <el-form :model="form" ref="formRef" :label-position="'top'">
      <el-row :gutter="20">
        <el-col :span="24">
          <el-form-item prop="ETSA001" :label="$t('ETSA001')">
            <el-input v-model="form.ETSA001" :placeholder="$t('ETSA001')" />
          </el-form-item>
        </el-col>
        <el-col :span="24">
          <el-form-item prop="ETSA002" :label="$t('ETSA002')">
            <el-input
              v-model="form.ETSA002"
              :placeholder="$t('ETSA002')"
            /> </el-form-item
        ></el-col>
        <el-col :span="24">
          <el-form-item prop="ETSA003" :label="$t('ETSA003')">
            <el-input v-model="form.ETSA003" :placeholder="$t('ETSA003')" />
          </el-form-item>
        </el-col>
        <el-col :span="24">
          <el-form-item prop="ETSA004" :label="$t('ETSA004')">
            <el-date-picker
              v-model="form.ETSA004"
              type="date"
              :style="{ width: '100%' }"
              format="YYYY-MM-DD"
              value-format="YYYY-MM-DD"
            /> </el-form-item
        ></el-col>
        <el-col :span="24">
          <el-form-item prop="ETSA005" :label="$t('ETSA005')">
            <el-date-picker
              v-model="form.ETSA005"
              type="date"
              :style="{ width: '100%' }"
              format="YYYY-MM-DD"
              value-format="YYYY-MM-DD"
            />
          </el-form-item>
        </el-col>
        <el-col :span="24">
          <el-form-item prop="ETSA006" :label="$t('ETSA006')">
            <el-input v-model="form.ETSA006" :placeholder="$t('ETSA006')" />
          </el-form-item>
        </el-col>
        <el-col :span="24">
          <el-form-item prop="ETSA007" :label="$t('ETSA007')">
            <el-input v-model="form.ETSA007" :placeholder="$t('ETSA007')" />
          </el-form-item>
        </el-col>
        <el-col :span="24">
          <el-form-item prop="ETSA008">
            <el-checkbox v-model="form.ETSA008" true-label="Y" false-label="N">
              {{ $t("ETSA008") }}
            </el-checkbox>
          </el-form-item>
        </el-col>
        <el-col :span="24">
          <el-form-item prop="ETSA009" :label="$t('ETSA009')">
            <el-input
              type="number"
              v-model="form.ETSA009"
              :placeholder="$t('ETSA009')"
            />
          </el-form-item>
        </el-col>
        <el-col :span="24">
          <el-form-item prop="ETSA010">
            <el-checkbox v-model="form.ETSA010" true-label="Y" false-label="N">
              {{ $t("ETSA010") }}
            </el-checkbox>
          </el-form-item>
        </el-col>
        <el-col :span="24">
          <el-form-item prop="ETSASTUS">
            <el-checkbox v-model="form.ETSASTUS" true-label="Y" false-label="N">
              {{ $t("ETSASTUS") }}
            </el-checkbox>
          </el-form-item>
        </el-col>
        <el-col :span="24">
          <el-form-item prop="ETSACRTID" :label="$t('ETSACRTID')">
            <el-input v-model="form.ETSACRTID" :placeholder="$t('ETSACRTID')" />
          </el-form-item>
        </el-col>
      </el-row>
    </el-form>
    <template #footer>
      <div class="dialog-footer">
        <el-button
          v-if="$attrs?.modelValue.mode === 'add'"
          type="primary"
          @click="onAdd"
          >{{ t("add") }}</el-button
        >
        <el-button
          v-if="$attrs?.modelValue.mode === 'edit'"
          type="primary"
          @click="onEdit"
          >{{ t("edit") }}</el-button
        >
        <el-button @click="onCancel">{{ t("cancel") }}</el-button>
      </div>
    </template>
  </el-dialog>
</template>

<script setup>
import { useStore } from "vuex";
import { onMounted, ref, computed, reactive, watch, useAttrs } from "vue";

import { useRouter } from "vue-router";
import { useI18n } from "vue-i18n";
import axios from "@/axios";
import { useState, ElNotification } from "@/utils";

const attrs = useAttrs();
const props = defineProps(["modalConfig"]);
const { locale, t } = useI18n();
const store = useStore();

const ENT = computed(() => {
  return store?.state?.global?.ENT || "";
});

const formRef = ref();

let [form, setForm] = useState({
  //QCBA003: "K-ACRA-2212280014",
});

const profile = computed(() => {
  return store?.state?.global?.profile || {};
});

const rules = reactive({
  ETSA003: [VALIDATIONS.isEmpty()],
  ETSA004: [VALIDATIONS.isEmpty()],
  ETSA005: [VALIDATIONS.isEmpty()],
});

const emit = defineEmits(["update:modelValue"]);

onMounted(() => {
  console.log(attrs);
});

watch(
  () => attrs?.modelValue?.data || {},
  (val) => {
    setForm(val);
  },
  { deep: true }
);

async function onEdit() {
  store.commit("global/setIsLoading", true);
  try {
    await axios({
      url: `/ETS/etsa_upd01`,
      method: "post",
      data: {
        ENT: ENT.value,
        USERID: profile.value.username,
        ...form.value,
      },
    });
    ElNotification({
      title: "Success",
      message: "存檔成功",
      type: "success",
    });

    emit("update:modelValue", { ...attrs.modelValue, isOpen: false });
  } catch (e) {
    console.log(e);
  }
  store.commit("global/setIsLoading", false);
}

async function onAdd() {
  store.commit("global/setIsLoading", true);
  try {
    await axios({
      url: `/ets/etsa_ins01`,
      method: "post",
      data: {
        ENT: ENT.value,
        USERID: profile.value.username,
        ...form.value,
      },
    });
    ElNotification({
      title: "Success",
      message: "存檔成功",
      type: "success",
    });

    emit("update:modelValue", { ...attrs.modelValue, isOpen: false });
  } catch (e) {
    console.log(e);
  }
  store.commit("global/setIsLoading", false);
}

/** 取消按钮 */
function onCancel() {
  // emit("update:modelValue", { ...attrs.modelValue, isOpen: false });
}
</script>
