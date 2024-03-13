<template>
  <el-dialog
    :draggable="true"
    width="600px"
    :title="modalConfig.mode === 'add' ? '新增 會議室' : '編輯 會議室'"
    @before-close="onClose"
    :v-bind="$attrs"
  >
    <el-form :model="form" :rules="rules" ref="formEl" label-width="120px">
      <el-row>
        <!-- 報工項次  -->

        <!-- "id": 1,
  "title": "2023",
  "start": "2023-04-01",
  "end": "2023-04-01",
  "all_day": 0,
  "url": "/test",
  "description": "2023",
  "user_id": "2019021101" -->
        <el-col :span="24">
          <el-form-item :label="$t('room_no')" prop="room_no">
            <el-select v-model="form.room_no" :placeholder="'room_no'">
              <el-option label="A棟1F會議室" :value="'101'" />
              <el-option label="A棟2F(訓練教室)大會議室" :value="'102'" />
              <el-option label="C棟1F會議室" :value="'301'" />
              <el-option label="D棟1F會議室" :value="'401'" />
            </el-select>
          </el-form-item>
        </el-col>
        <el-col :span="24">
          <el-form-item :label="$t('title')" prop="title">
            <el-input type="title" v-model="form.title"></el-input>
          </el-form-item>
        </el-col>
        <el-col :span="24">
          <el-form-item :label="$t('all_day')" prop="all_day">
            <el-checkbox
              v-model="form.all_day"
              :false-label="0"
              :true-label="1"
              @change="onAllDayChange"
            />
          </el-form-item>
        </el-col>
        <el-col :span="24">
          <el-form-item :label="$t('dateRange')" prop="dateRange">
            <el-date-picker
              v-model="form.dateRange"
              :type="form.all_day === 1 ? 'daterange' : 'datetimerange'"
              range-separator="至"
              start-placeholder="開始時間"
              end-placeholder="結束時間"
              :disabled-date="onDisabledDate"
              :format="DATETIME_FORMAT"
              :value-format="DATETIME_FORMAT"
              @change="onDatePickerChange"
              :popper-options="{ placement: 'auto' }"
            />
          </el-form-item>
        </el-col>

        <el-col :span="24">
          <el-form-item :label="$t('mailaddress')" prop="mailaddress">
            <!-- <el-input v-model="form.mailaddress" type="textarea"></el-input> -->
            <!-- {{ form.mailaddress }} -->
            <vue-tags-input
              placeholder="add user email"
              :tags="tags"
              @tags-changed="
                (newTags) => {
                  console.log(newTags);
                  tags = newTags.map((o) => o.text);
                  form.mailaddress = newTags.map((o) => o.text).join(';');
                }
              "
            />
          </el-form-item>
        </el-col>

        <el-col :span="24">
          <el-form-item :label="$t('description')" prop="description">
            <el-input v-model="form.description" type="textarea"></el-input>
          </el-form-item>
        </el-col>
      </el-row>
    </el-form>

    <template #footer>
      <span class="dialog-footer">
        <el-button @click="onClose">{{ $t("cancel") }}</el-button>
        <el-button type="primary" @click="submitform"
          >{{ $t("submit") }}
        </el-button>
      </span>
    </template>
  </el-dialog>
</template>

<script setup>
import { useStore } from "vuex";
import {
  ref,
  unref,
  computed,
  reactive,
  watch,
  toRefs,
  onMounted,
  useAttrs,
} from "vue";
import { useRoute, useRouter } from "vue-router";
import { useI18n } from "vue-i18n";
import moment from "moment";
import axios from "@/axios";
import { VALIDATIONS, useState } from "@/utils";

import { useVModel } from "@vueuse/core";

const INITIAL_FORMDATA = {
  dateRange: "",
  all_day: 0,
  mailaddress: "",
};

const props = defineProps(["modalConfig"]);
const emit = defineEmits();
const attrs = useAttrs();
// const { data } = props;
const { t } = useI18n();
const store = useStore();
const router = useRouter();

const [form, setForm] = useState(INITIAL_FORMDATA);
// const [infoList, setInfoList] = useState([]);

const modalConfig = useVModel(props, "modalConfig", emit);

const rules = reactive({
  start: VALIDATIONS.isEmpty(),
  title: VALIDATIONS.isEmpty(),
  //   description: VALIDATIONS.isEmpty(),
  dateRange: VALIDATIONS.dateRange(),
});

const formEl = ref(null);
const tags = ref([]);

const ENT = computed(() => store?.state?.global?.ENT || "");

const DATETIME_FORMAT = "YYYY-MM-DD HH:mm";

const profile = computed(() => {
  return store?.state?.global?.profile || {};
});
watch(
  () => props?.modalConfig?.isOpen,
  (val, prev) => {
    if (val) {
      if (props?.modalConfig?.data) {
        const record = props?.modalConfig?.data || {};
        const { start, end } = record;
        const dateRange = [start, end];
        const mailaddress = record?.mailaddress || "";
        const newTags = mailaddress ? mailaddress.split(";") : [];
        form.value = { ...record, dateRange };
        tags.value = newTags;
      }
    } else {
      setForm({ ...INITIAL_FORMDATA });
    }
  },
  { deep: true }
);

function onAllDayChange(val) {
  const { start, end } = val;
  form.value.dateRange = [];
  const s1 = moment(start).startOf("day").format(DATETIME_FORMAT);
  const e1 = moment(end).endOf("day").format(DATETIME_FORMAT);
  setForm({ ...form.value, start: s1, end: e1 });
}
function onDatePickerChange(dateRange) {
  const s = dateRange?.[0];
  const e = dateRange?.[1];
  const start = moment(s).format(DATETIME_FORMAT);
  const end = moment(e).format(DATETIME_FORMAT);
  setForm({ ...form.value, start, end });
}

function onDisabledDate(val) {
  let result = true;
  const targetDate = moment(val);
  const today = moment();
  const formattedToday = today.format("YYYY-MM-DD");
  const formattedTargetDate = targetDate.format("YYYY-MM-DD");
  if (formattedTargetDate < formattedToday) {
    result = true;
  } else {
    result = false;
  }
  return result;
}

function onClose() {
  modalConfig.value.isOpen = false;
  props?.onClose();
}

async function submitform() {
  const formObj = formEl?.value;

  if (formObj) {
    await formObj.validate((valid, fields) => {
      if (valid) {
        if (props?.modalConfig?.mode === "add") {
          onPost();
        } else {
          onPut();
        }
      } else {
        console.log("error submit!!");
      }
    });
  }
}

async function onPost() {
  store.commit("global/setIsLoading", true);

  try {
    const data = {
      ...form.value,
      ENT: ENT.value,
      user_id: profile.value?.username,
    };
    const res = await axios({
      url: "/calendar/events",
      method: "POST",
      data,
    });
    modalConfig.value.isOpen = false;
    props.onClose();
  } catch (e) {
    console.log(e);
  }
  store.commit("global/setIsLoading", false);
}

async function onPut() {
  store.commit("global/setIsLoading", true);

  try {
    const data = {
      ...form.value,
      ENT: ENT.value,
      user_id: profile.value?.username,
    };

    //console.log("form.data >>>", data);

    const res = await axios({
      url: `/calendar/events/${form.value.id}`,
      method: "PUT",
      data,
    });
    modalConfig.value.isOpen = false;
  } catch (e) {
    console.log(e);
  }
  store.commit("global/setIsLoading", false);
}
</script>
