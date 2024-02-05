<template>
  <el-dialog
    :width="600"
    v-model="modelValue.isOpen"
    :title="`${modelValue.mode === 'add' ? $t('add') : $t('edit')} ${$t(
      'title_ETST003'
    )}`"
  >
    <el-form :model="form" ref="formRef" :rules="rules" :label-position="'top'">
      <el-row :gutter="20">
        <!-- ETSB001 員工編號 -->
        <el-col :xs="24" :sm="12">
          <el-form-item :label="$t('ETSB001')" prop="ETSB001">
            <el-input
              :placeholder="$t('ETSB001')"
              type="text"
              v-model="form.ETSB001"
            >
            </el-input>
          </el-form-item>
        </el-col>
        <!-- ETSB002 員工姓名 -->
        <el-col :xs="24" :sm="12">
          <el-form-item :label="$t('ETSB002')" prop="ETSB002">
            <el-input
              :placeholder="$t('ETSB002')"
              type="text"
              v-model="form.ETSB002"
            >
            </el-input>
          </el-form-item>
        </el-col>
        <!-- ETSB003 學歷 -->
        <el-col :xs="24" :sm="12">
          <el-form-item :label="$t('ETSB003')" prop="ETSB003">
            <el-select
              v-model="form.ETSB003"
              :placeholder="$t('ETSB003')"
              :style="{ width: '100%' }"
            >
              <el-option label="高中" :value="'高中'" />
              <el-option label="大學" :value="'大學'" />
              <el-option label="碩士" :value="'碩士'" />
              <el-option label="博士" :value="'博士'" />
            </el-select>
          </el-form-item>
        </el-col>
        <!-- ETSB004 工作年資 -->
        <!-- <el-col :xs="24" :sm="12">
          <el-form-item :label="$t('ETSB004')" prop="ETSB004">
            <el-input
              :placeholder="$t('ETSB004')"
              type="number"
              v-model="form.ETSB004"
            >
            </el-input>
          </el-form-item>
        </el-col> -->
        <!-- ETSB005 入廠日期 -->
        <el-col :xs="24" :sm="12">
          <el-form-item :label="$t('ETSB005')" prop="ETSB005">
            <el-date-picker
              v-model="form.ETSB005"
              type="date"
              :style="{ width: '100%' }"
              format="YYYY-MM-DD"
              value-format="YYYY-MM-DD"
            />
          </el-form-item>
        </el-col>
        <!-- ETSB006 生日 -->
        <el-col :xs="24" :sm="12">
          <el-form-item :label="$t('ETSB006')" prop="ETSB006">
            <el-date-picker
              v-model="form.ETSB006"
              type="date"
              :style="{ width: '100%' }"
              format="YYYY-MM-DD"
              value-format="YYYY-MM-DD"
            />
          </el-form-item>
        </el-col>
        <!-- ETSB007 性別 -->
        <el-col :xs="24" :sm="12">
          <el-form-item :label="$t('ETSB007')" prop="ETSB007">
            <el-select
              v-model="form.ETSB007"
              :placeholder="$t('ETSB007')"
              :style="{ width: '100%' }"
            >
              <el-option label="男" :value="'M'" />
              <el-option label="女" :value="'F'" />
            </el-select>
          </el-form-item>
        </el-col>
        <!-- ETSBSTUS 狀態 -->
        <el-col :xs="24" :sm="12">
          <el-form-item :label="$t('ETSBSTUS')" prop="ETSBSTUS">
            <el-select
              v-model="form.ETSBSTUS"
              :placeholder="$t('ETSBSTUS')"
              :style="{ width: '100%' }"
            >
              <el-option label="Y" :value="'Y'" />
              <el-option label="N" :value="'N'" />
            </el-select>
          </el-form-item>
        </el-col>
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
  ETSB001: [VALIDATIONS.isEmpty()],
  ETSB002: [VALIDATIONS.isEmpty()],
  ETSB003: [VALIDATIONS.isEmpty()],
  ETSB004: [VALIDATIONS.isEmpty()],
  ETSB005: [VALIDATIONS.isEmpty()],
  ETSB006: [VALIDATIONS.isEmpty()],
});

const emit = defineEmits(["update:modelValue"]);

onMounted(() => {});

const INITIAL_FORM = {
  ETSBSTUS: "Y",
  ETSB009: "N",
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
            url: `/ets/etsb_upd01`,
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

async function onAdd() {
  const formObj = formRef.value;
  if (formObj) {
    formObj.validate(async (valid) => {
      if (valid) {
        store.commit("global/setIsLoading", true);
        try {
          await axios({
            url: `/ets/etsb_ins01`,
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

/** 取消按钮 */
function onCancel() {
  emit("update:modelValue", { ...props.modelValue, isOpen: false });
}
</script>
