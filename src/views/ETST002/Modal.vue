<template>
  <el-dialog
    :width="600"
    v-model="modelValue.isOpen"
    :title="`${modelValue.mode === 'add' ? $t('add') : $t('edit')} ${$t(
      'title_ETST002'
    )}`"
  >
    <el-form :model="form" ref="formRef" :rules="rules" :label-position="'top'">
      <el-row :gutter="20">
        <!-- 課程代碼 -->
        <!-- <el-col :span="24">
          <el-form-item prop="ETSA001" :label="$t('ETSA001')" >
            <el-input
              v-model="form.ETSA001"
              :placeholder="$t('ETSA001')"
              :disabled="modelValue.mode === 'edit'" 
            />
          </el-form-item>
        </el-col> -->
        <!-- 課程名稱  -->
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
        <el-col :span="12">
          <el-form-item prop="ETSA004" :label="$t('ETSA004')">
            <el-date-picker
              v-model="form.ETSA004"
              type="date"
              :style="{ width: '100%' }"
              format="YYYY-MM-DD"
              value-format="YYYY-MM-DD"
            /> </el-form-item
        ></el-col>
        <el-col :span="12">
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
        <el-col :span="12">
          <el-form-item prop="ETSA006" :label="$t('ETSA006')">
            <Autocomplete
              v-model="form.ETSA006"
              :onFetch="getDepList"
              width="380px"
            >
              <el-input
                :placeholder="$t('ETSA006')"
                type="text"
                v-model="form.ETSA006"
              >
              </el-input>
            </Autocomplete>
          </el-form-item>
        </el-col>
        <el-col :span="12">
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
        <el-col :xs="24" :sm="12">
          <el-form-item :label="$t('ETSA011')" prop="ETSA011">
            <el-select
              v-model="form.ETSA011"
              :placeholder="$t('ETSA011')"
              :style="{ width: '100%' }"
            >
              <el-option label="內訓" :value="'內訓'" />
              <el-option label="外訓" :value="'外訓'" />
            </el-select>
          </el-form-item>
        </el-col>
        <el-col :xs="24" :sm="12">
          <el-form-item prop="ETSA009" :label="$t('ETSA009')">
            <el-input
              type="number"
              v-model="form.ETSA009"
              :placeholder="$t('ETSA009')"
            />
          </el-form-item>
        </el-col>
        <el-col :span="12">
          <el-form-item prop="ETSA010">
            <el-checkbox v-model="form.ETSA010" true-label="Y" false-label="N">
              {{ $t("ETSA010") }}
            </el-checkbox>
          </el-form-item>
        </el-col>

        <el-col :span="12">
          <el-form-item prop="ETSASTUS">
            <el-checkbox v-model="form.ETSASTUS" true-label="Y" false-label="N">
              {{ $t("ETSASTUS") }}
            </el-checkbox>
          </el-form-item>
        </el-col>

        <!-- <el-col :span="24">
          <el-form-item :label="$t('ETSACRTID')">
            <el-input
              :placeholder="$t('ETSACRTID')"
              :value="profile.username"
              disabled
            />
          </el-form-item>
        </el-col> -->
        <el-col :span="24">
          <el-form-item :label="$t('ETSACRTID')">
            <el-input
              :placeholder="$t('ETSACRTID')"
              v-model="form.ETSACRTID"
              disabled
            />
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
  ETSA002: [VALIDATIONS.isEmpty()],
  ETSA003: [VALIDATIONS.isEmpty()],
  ETSA004: [VALIDATIONS.isEmpty()],
  ETSA005: [VALIDATIONS.isEmpty()],
  ETSA006: [VALIDATIONS.isEmpty()],
  ETSA009: [VALIDATIONS.isEmpty()],
  ETSA011: [VALIDATIONS.isEmpty()],
});

const emit = defineEmits(["update:modelValue"]);

onMounted(() => {});

const INITIAL_FORM = {
  ETSASTUS: "Y",
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
            url: `/ets/etsa_upd01`,
            method: "post",
            data: {
              ENT: ENT.value,
              ...form.value,
              USERID: profile.value.username,
              ETSACRTID: profile.value.username,
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
            url: `/ets/etsa_ins01`,
            method: "post",
            data: {
              ENT: ENT.value,
              ...form.value,
              USERID: profile.value.username,
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
