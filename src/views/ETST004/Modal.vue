<template>
  <el-dialog
    :width="600"
    v-model="modelValue.isOpen"
    :title="`${modelValue.mode === 'add' ? $t('add') : $t('edit')} ${$t(
      'title_ETST004'
    )}`"
  >
    <el-form :model="form" ref="formRef" :rules="rules" :label-position="'top'">
      <el-row :gutter="20">
        <el-col :span="24">
          <!-- 員工編號 -->
          <el-form-item prop="ETSC001" :label="$t('ETSC001')">
            <el-input
              v-model="form.ETSC001"
              :placeholder="$t('ETSC001')"
              :disabled="modelValue.mode === 'edit'"
            />
          </el-form-item>
        </el-col>
        <el-col :span="24">
          <!-- 單位別  -->
          <el-form-item prop="ETSC002" :label="$t('ETSC002')">
            <Autocomplete
              v-model="form.ETSC002"
              :onFetch="getDepList"
              width="380px"
            >
              <el-input
                :placeholder="$t('ETSC002')"
                type="text"
                v-model="form.ETSC002"
              >
              </el-input>
            </Autocomplete> </el-form-item
        ></el-col>
        <el-col :span="24">
          <!-- 職務代碼 -->
          <el-form-item prop="ETSC003" :label="$t('ETSC003')">
            <el-input v-model="form.ETSC003" :placeholder="$t('ETSC003')" />
          </el-form-item>
        </el-col>
        <el-col :span="12">
          <!-- 期間(報到日期或調動日期) -->
          <el-form-item prop="ETSC004" :label="$t('ETSC004')">
            <el-date-picker
              v-model="form.ETSC004"
              type="date"
              :style="{ width: '100%' }"
              format="YYYY-MM-DD"
              value-format="YYYY-MM-DD"
            /> </el-form-item
        ></el-col>
      </el-row>
    </el-form>
    <template #footer>
      <div class="dialog-footer">
        <el-button
          v-if="modelValue.mode === 'add'"
          type="primary"
          @click="onAdd"
          >{{ t("save") }}</el-button
        >
        <el-button
          v-if="modelValue.mode === 'edit'"
          type="primary"
          @click="onEdit"
          >{{ t("save") }}</el-button
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
import { useState, VALIDATIONS, ElNotification } from "@/utils";

const attrs = useAttrs();
const props = defineProps(["modelValue", "onChange"]);
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
  ETSC001: [VALIDATIONS.isEmpty()],
});

const emit = defineEmits(["update:modelValue"]);

onMounted(() => {});

const INITIAL_FORM = {
  ETSCSTUS: "Y",
};

watch(
  () => props?.modelValue?.data || {},
  (val) => {
    setForm({ ...INITIAL_FORM, ...val });
  },
  { deep: true }
);

async function onEdit() {
  const formObj = formRef.value;
  if (formObj) {
    formObj.validate(async (valid) => {
      if (valid) {
        store.commit("global/setIsLoading", true);
        try {
          await axios({
            url: `/ets/etsc_upd01`,
            method: "post",
            data: {
              ENT: ENT.value,
              USERID: profile.value.username,
              ETSCCRTID: profile.value.username,
              ...form.value,
            },
          });
          ElNotification({
            title: "Success",
            message: "存檔成功",
            type: "success",
          });
          if (props.onChange) props.onChange();
          emit("update:modelValue", { ...props.modelValue, isOpen: false });
        } catch (e) {
          console.log(e);
        }
        store.commit("global/setIsLoading", false);
      } else {
        console.log("error submit!!");
      }
    });
  }
}

async function onAdd() {
  const formObj = formRef.value;
  if (formObj) {
    formObj.validate(async (valid) => {
      if (valid) {
        store.commit("global/setIsLoading", true);
        try {
          await axios({
            url: `/ets/etsc_ins01`,
            method: "post",
            data: {
              ENT: ENT.value,
              ...form.value,
              USERID: profile.value.username,
              ETSCCRTID: profile.value.username,
            },
          });
          ElNotification({
            title: "Success",
            message: "存檔成功",
            type: "success",
          });

          if (props.onChange) props.onChange();
          emit("update:modelValue", { ...props.modelValue, isOpen: false });
        } catch (e) {
          console.log(e);
        }
        store.commit("global/setIsLoading", false);
      } else {
        console.log("error submit!!");
      }
    });
  }
}
const global = computed(() => store?.state?.global || "");
/*
 * 取得部門列表
 */
async function getDepList() {
  const ENT = global?.value?.ENT || "";
  try {
    const res = await axios({
      url: "/ets/ets_dept_get01",
      method: "post",
      showError: false,
      showLoading: false,
      data: {
        ENT,
        SITE: "0001",
      },
    });

    const data = res?.data || [];
    const list = data.map((obj) => {
      const val = obj.OOEG001 || "";
      return { value: val, label: `${obj.OOEG001}/${obj.OOEFL003}` };
    });
    return list;
  } catch (e) {
    console.log(">>>>>>>>>>", e);
  }
  return [];
}

/** 取消按钮 */
function onCancel() {
  emit("update:modelValue", { ...props.modelValue, isOpen: false });
}
</script>
