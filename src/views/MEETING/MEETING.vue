<!-- 專門處理所有地方的autocomplete -->
<template>
  <Layout :auth="true">
    <teleport to="#portal-target">
      <h2>{{ $t("title_MEETING") }}</h2>
    </teleport>
    <el-form
      class="search-bar"
      @submit.native.prevent
      :model="form"
      status-icon
      :rules="rules"
      ref="formRef"
      label-width="80px"
      :label-position="'top'"
    >
      <div class="search-input">
        <el-row :gutter="12">
          <el-col :xs="24" :sm="4">
            <el-form-item :label="$t('room_no')" prop="room_no">
              <el-select v-model="form.room_no">
                <!-- <el-option
                  v-for="item in room_no_options || []"
                  :label="item.label"
                  :value="item.value"
                /> -->
                <el-option label="A棟1F會議室" :value="'101'" />
                <el-option label="A棟2F(訓練教室)大會議室" :value="'102'" />
                <el-option label="C棟1F會議室" :value="'301'" />
                <el-option label="D棟1F會議室" :value="'401'" />
              </el-select>
            </el-form-item>
          </el-col>
          <el-col :xs="24" :sm="4">
            <el-form-item :label="$t('start')" prop="start">
              <el-date-picker
                v-model="form.start"
                type="date"
                :style="{ width: '100%' }"
                format="YYYY-MM-DD"
                value-format="YYYY-MM-DD"
              />
            </el-form-item>
          </el-col>
          <el-col :xs="24" :sm="4">
            <el-form-item :label="$t('end')" prop="end">
              <el-date-picker
                v-model="form.end"
                type="date"
                :style="{ width: '100%' }"
                format="YYYY-MM-DD"
                value-format="YYYY-MM-DD"
              />
            </el-form-item>
          </el-col>
          <!-- <el-col :xs="24" :sm="6">
            <el-form-item :label="$t('title')" prop="title">
              <el-date-picker
                type="daterange"
                v-model="form.dateRange"
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
          </el-col> -->
          <!-- <el-col :xs="24" :sm="4">
            <el-form-item :label="$t('ETSC004')" prop="ETSC004">
              <el-date-picker
                v-model="form.ETSC004"
                type="date"
                :style="{ width: '100%' }"
                format="YYYY-MM-DD"
                value-format="YYYY-MM-DD"
              />
            </el-form-item>
          </el-col> -->
        </el-row>
      </div>
      <div class="search-btns">
        <el-space :style="{ width: '100%', justifyContent: 'flex-end' }">
          <el-button plain @click="onClean">
            清除條件
            <el-icon class="el-icon--right">
              <Brush />
            </el-icon>
          </el-button>
          <el-button type="primary" @click="onSearch">
            {{ $t("search") }}
            <el-icon class="el-icon--right">
              <Search />
            </el-icon> </el-button
        ></el-space>
      </div>

      <div class="search-btns"></div>
    </el-form>
    <div style="display: flex; width: 100%; justify-content: flex-end">
      <el-button type="primary" @click="onOpen()">
        預約會議室
        <el-icon class="el-icon--right">
          <Plus />
        </el-icon>
      </el-button>
    </div>
    <el-table :data="events" :style="{ marginTop: '20px' }">
      <el-table-column
        v-for="fieldKey in columns"
        :prop="fieldKey"
        :label="$t(fieldKey)"
        align="left"
        v-bind="columnsSetting[fieldKey]"
      />
      <el-table-column :label="$t('action')" align="center" width="120x">
        <template #default="scope">
          <el-button
            size="small"
            type="primary"
            :icon="Edit"
            plain
            circle
            @click="onEdit(scope.row)"
          >
            <el-icon><Edit /></el-icon>
          </el-button>
          <el-button
            size="small"
            type="danger"
            :icon="Edit"
            plain
            circle
            @click="onDelete(scope.row)"
          >
            <el-icon><Delete /></el-icon>
          </el-button>
        </template>
      </el-table-column>
    </el-table>
  </Layout>
  <!-- <div style="display: flex; width: 100%; justify-content: flex-end">
    <el-button type="primary" @click="onOpen()">
      預約
      <el-icon class="el-icon--right">
        <Plus />
      </el-icon>
    </el-button>
  </div> -->

  <!-- <vue-cal
    class="vuecal--green-theme"
    locale="zh-cn"
    :disable-views="['years', 'year']"
    active-view="month"
    :events="events"
    style="width: 100%"
    xsmall
  >
  </vue-cal> -->

  <Modal
    v-model="modalConfig.isOpen"
    :modalConfig="modalConfig"
    :onClose="getList"
    v-bind="$props"
  />
</template>
<script setup>
import { useStore } from "vuex";

import axios from "@/axios";

import {
  ref,
  computed,
  onMounted,
  onUnmounted,
  // defineEmits,
  reactive,
} from "vue";

import { useI18n } from "vue-i18n";
import _ from "lodash";
import { useState, jsonToExcel, ElNotification } from "@/utils";
import moment from "moment";

import Modal from "./Modal.vue";

const emit = defineEmits();

const props = defineProps([]);
// const attrs = useAttrs();

const { t } = useI18n();

const DATETIME_FORMAT = "YYYY-MM-DD HH:mm";
const selectedDate = ref(moment().format("YYYY-MM-DD HH:mm"));

const events = ref([]);
const modalConfig = ref({ isOpen: false, mode: "edit" });
//const form = ref({});
const formRef = ref();
const store = useStore();

const profile = computed(() => {
  return store?.state?.global?.profile || {};
});

const rules = reactive({
  // ETSA001: VALIDATIONS.isEmpty(),
});

onMounted(() => {
  getList();
});

onUnmounted(() => {});

// watch(
//   () => props?.modalValue,
//   () => {
//     // console.log(props);
//   },
//   { deep: true }
// );

const room_no_options = computed(() => {
  const temp = _.uniqBy(events?.value || [], "room_no").map((obj) => ({
    label: obj?.["room_no"],
    value: obj?.["room_no"],
  }));
  return temp;
});

let [form, setForm] = useState({
  start: moment(new Date()).format("YYYY-MM-DD"),
  end: moment(new Date()).add(2, "months").format("YYYY-MM-DD"), // 将 end 设置为下个月
});

const ENT = computed(() => store?.state?.global?.ENT || "");

const columnsSetting = computed(() => {
  return {
    // id: {
    //   width: 40,
    // },
    room_no: {
      width: 150,
      align: "left",
      fixed: "left",
    },
    title: {
      width: 150,
      align: "left",
      fixed: "left",
    },
    user_id: {
      width: 150,
    },
    start: { width: 150, align: "left" },
    end: { width: 150, align: "left" },
    description: {
      // width: 300,
    },
    mailaddress: {
      // width: 300,
    },
  };
});

const columns = computed(() => {
  return Object.keys(columnsSetting?.value || []);
});

function onClean() {
  form.value = {};
}

function onSearch() {
  const formObj = formRef.value;
  if (formObj) {
    formObj.validate((valid) => {
      if (valid) {
        getList();
      } else {
        console.log("error submit!!");
      }
    });
  }
}

function onOpen() {
  modalConfig.value = { ...modalConfig.value, isOpen: true, mode: "add" };
}

async function getList() {
  store.commit("global/setIsLoading", true);
  try {
    const res = await axios({
      url: `/calendar/events`,
      method: "GET",
      showError: true,
      params: {
        ...form.value,
      },
    });
    const newEvents = res?.data.map((o) => {
      const startData = moment(o.start).format("YYYY-MM-DD HH:mm");
      const endData = moment(o.end).format("YYYY-MM-DD HH:mm");
      return {
        ...o,
        start: startData,
        end: endData,
      };
    });
    events.value = newEvents || [];

    const firstDate = new Date(res?.data?.[0]?.start);
    selectedDate.value = firstDate;
    //console.log(newEvents);
  } catch (e) {
    console.log(e);
  }
  store.commit("global/setIsLoading", false);
}

async function onEdit(record) {
  modalConfig.value = { ...modalConfig, isOpen: true, data: record };
}

async function onDelete(record) {
  store.commit("global/setIsLoading", true);
  try {
    const res = await axios({
      url: `/calendar/events/${record.id}`,
      method: "DELETE",
      params: {
        id: record.id,
        user_id: profile.value?.username,
      },
    });
    await getList();
  } catch (e) {
    console.log(e);
  }
  store.commit("global/setIsLoading", false);
}

defineExpose({});
</script>

<style lang="scss">
.vuecal__cell {
  min-height: 60px;
}
</style>
