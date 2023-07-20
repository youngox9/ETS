<template>
  <el-dialog
    :width="600"
    v-model="modelValue.isOpen"
    :title="`${modelValue.mode === 'add' ? $t('add') : $t('edit')} ${$t(
      'title_ETST005'
    )}`"
  >
    <el-form :model="form" ref="formRef" :rules="rules" :label-position="'top'">
      <el-row :gutter="12">
        <!-- ETSD001 課程編號 -->
        <el-col :xs="24" :sm="12">
          <el-form-item :label="$t('ETSD001')" prop="ETSD001">
            <DepDropdown
              apiUrl="/ets/ets_etsa001_get01"
              labelKey="ETSA002"
              valueKey="ETSA001"
              v-model="form.ETSD001"
              :onClose="getETSD001Data"
            >
              <el-input
                :placeholder="'ETSD001'"
                type="text"
                v-model="form.ETSD001"
              >
              </el-input>
            </DepDropdown>
          </el-form-item>
        </el-col>
        <!-- ETSD002 員工編號 -->
        <el-col :xs="24" :sm="12">
          <el-form-item :label="$t('ETSD002')" prop="ETSD002">
            <DepDropdown type="employee" v-model="form.ETSD002">
              <el-input
                :placeholder="'ETSD002'"
                type="text"
                v-model="form.ETSD002"
              >
              </el-input>
            </DepDropdown>
          </el-form-item>
        </el-col>
        <!-- ETSD003 訓練日期 -->
        <el-col :xs="24" :sm="12">
          <el-form-item :label="$t('ETSD003')" prop="ETSD003">
            <el-date-picker
              v-model="form.ETSD003"
              type="date"
              :style="{ width: '100%' }"
              format="YYYY-MM-DD"
              value-format="YYYY-MM-DD"
            />
          </el-form-item>
        </el-col>
        <!-- ETSD004 訓練單位 -->
        <el-col :xs="24" :sm="12">
          <el-form-item :label="$t('ETSD004')" prop="ETSD004">
            <Autocomplete
              v-model="form.ETSD004"
              :onFetch="getDepList"
              width="380px"
            >
              <el-input
                :placeholder="'ETSD004'"
                type="text"
                v-model="form.ETSD004"
              >
              </el-input>
            </Autocomplete>
          </el-form-item>
        </el-col>
        <!-- ETSD005 時數 -->
        <el-col :xs="24" :sm="12">
          <el-form-item :label="$t('ETSD005')" prop="ETSD005">
            <el-input
              :placeholder="'ETSD005'"
              type="text"
              v-model="form.ETSD005"
            >
            </el-input>
          </el-form-item>
        </el-col>
        <!-- ETSD006 證照管理(有/無) -->
        <el-col :xs="24" :sm="12">
          <el-form-item :label="$t('ETSD006')" prop="ETSD006">
            <el-select
              v-model="form.ETSD006"
              :placeholder="'ETSD006'"
              :style="{ width: '100%' }"
            >
              <el-option label="有" :value="'Y'" />
              <el-option label="無" :value="'N'" />
            </el-select>
          </el-form-item>
        </el-col>
        <!-- ETSD007 登錄人員 -->
        <el-col :xs="24" :sm="24">
          <el-form-item :label="$t('ETSD007')" prop="ETSD007">
            <DepDropdown type="employee" v-model="form.ETSD007">
              <el-input
                v-if="modelValue.mode === 'add'"
                :placeholder="'ETSD007'"
                type="text"
                :value="profile.username"
                disabled
              />
              <el-input
                v-if="modelValue.mode === 'edit'"
                :placeholder="'ETSD007'"
                type="text"
                v-model="form.ETSD007"
              />
            </DepDropdown>
          </el-form-item>
        </el-col>
        <!-- ETSD008 卡鐘時間(起) -->
        <el-col :xs="24" :sm="12">
          <el-form-item :label="$t('ETSD008')" prop="ETSD008">
            <el-date-picker
              v-model="form.ETSD008"
              type="date"
              :style="{ width: '100%' }"
              format="YYYY-MM-DD"
              value-format="YYYY-MM-DD"
            />
          </el-form-item>
        </el-col>
        <!-- ETSD009 卡鐘時間(迄) -->
        <el-col :xs="24" :sm="12">
          <el-form-item :label="$t('ETSD009')" prop="ETSD009">
            <el-date-picker
              v-model="form.ETSD009"
              type="date"
              :style="{ width: '100%' }"
              format="YYYY-MM-DD"
              value-format="YYYY-MM-DD"
            />
          </el-form-item>
        </el-col>
        <!-- ETSD010 上課開始時間 -->
        <el-col :xs="24" :sm="12">
          <el-form-item :label="$t('ETSD010')" prop="ETSD010">
            <el-input
              :placeholder="'ETSD010'"
              type="text"
              v-model="form.ETSD010"
            >
            </el-input>
          </el-form-item>
        </el-col>
        <!-- ETSD011 上課結束時間 -->
        <el-col :xs="24" :sm="12">
          <el-form-item :label="$t('ETSD011')" prop="ETSD011">
            <el-input
              :placeholder="'ETSD011'"
              type="text"
              v-model="form.ETSD011"
            >
            </el-input>
          </el-form-item>
        </el-col>
        <!-- ETSD012 上課地點 -->
        <el-col :xs="24" :sm="24">
          <el-form-item :label="$t('ETSD012')" prop="ETSD012">
            <el-input
              :placeholder="'ETSD012'"
              type="text"
              v-model="form.ETSD012"
            >
            </el-input>
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
  ETSD001: [VALIDATIONS.isEmpty()],
  ETSD002: [VALIDATIONS.isEmpty()],
  ETSD003: [VALIDATIONS.isEmpty()],
  ETSD004: [VALIDATIONS.isEmpty()],
  ETSD005: [VALIDATIONS.isEmpty()],
  ETSD006: [VALIDATIONS.isEmpty()],
  ETSD010: [VALIDATIONS.isEmpty()],
  ETSD011: [VALIDATIONS.isEmpty()],
  ETSD012: [VALIDATIONS.isEmpty()],
});

const emit = defineEmits(["update:modelValue"]);

const global = computed(() => store?.state?.global || "");

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
            url: `/ets/etsd_upd01`,
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
            url: `/ets/etsd_ins01`,
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

async function getETSD001Data() {
  const ENT = global?.value?.ENT || "";
  const username = global?.value?.profile?.username || "";

  try {
    const res = await axios({
      url: "/ets/etsa_to_etsd_get01",
      method: "post",
      showError: false,
      showLoading: false,
      data: {
        ENT,
        ETSA001: form.value.ETSD001,
        USERID: username,
      },
    });

    const data = res?.data?.[0] || {};
    setForm({ ...form?.value, ...data });
    console.log(data);
  } catch (e) {
    console.log(">>>>>>>>>>", e);
  }
  return [];
}
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
        USERID: profile.value.username,
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
