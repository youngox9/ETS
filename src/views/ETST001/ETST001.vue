<template>
  <Layout :auth="true">
    <teleport to="#portal-target">
      <h2>{{ $t("title_ETST001") }}</h2>
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
            <el-form-item :label="$t('ETSB001')" prop="ETSB001">
              <el-input
                :placeholder="'ETSB001'"
                type="text"
                v-model="form.ETSB001"
                autocomplete="off"
                @input="onChange"
              >
              </el-input>
            </el-form-item>
          </el-col>
          <el-col :xs="24" :sm="4">
            <el-form-item :label="$t('OOAG003')" prop="OOAG003">
              <Autocomplete
                v-model="form.OOAG003"
                :onFetch="getDepList"
                width="380px"
              >
                <el-input
                  :placeholder="'OOAG003'"
                  type="text"
                  v-model="form.OOAG003"
                  autocomplete="off"
                  @input="onChange"
                >
                </el-input>
              </Autocomplete>
            </el-form-item>
          </el-col>
          <el-col :xs="24" :sm="4">
            <el-form-item :label="$t('OOAGMODDT_S')" prop="OOAGMODDT_S">
              <el-date-picker
                v-model="form.OOAGMODDT_S"
                type="date"
                :style="{ width: '100%' }"
                format="YYYY-MM-DD"
                value-format="YYYY-MM-DD"
              />
            </el-form-item>
          </el-col>
          <el-col :xs="24" :sm="4">
            <el-form-item :label="$t('OOAGMODDT_E')" prop="OOAGMODDT_E">
              <el-date-picker
                v-model="form.OOAGMODDT_E"
                type="date"
                :style="{ width: '100%' }"
                format="YYYY-MM-DD"
                value-format="YYYY-MM-DD"
              />
            </el-form-item>
          </el-col>
          <el-col :xs="24" :sm="4">
            <el-form-item :label="$t('OOAGSTUS')" prop="OOAGSTUS">
              <el-select v-model="form.OOAGSTUS" :placeholder="'OOAGSTUS'">
                <el-option label="Y" :value="'Y'" />
                <el-option label="N" :value="'N'" />
              </el-select>
            </el-form-item>
          </el-col>
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
    </el-form>
    <el-divider />
    <div
      :style="{
        display: 'flex',
        justifyContent: 'flex-end',
        alignItems: 'flex-end',
        flexWrap: 'wrap',
        width: '100%',
        marginBottom: '12px',
      }"
    >
      <el-tooltip content="Printer" placement="top">
        <el-button plain type="primary" @click="onPrint(nowPageItem)">
          {{ $t("print") }}
          <el-icon class="el-icon--right">
            <Printer />
          </el-icon>
        </el-button>
      </el-tooltip>
    </div>

    <el-pagination
      v-if="list?.length"
      :style="{ justifyContent: 'center', marginTop: '12px' }"
      background
      v-model:currentPage="nowPage"
      :page-count="list.length"
      layout="prev, pager, next"
    />
    <el-divider />
    <div
      :style="{
        backgroundColor: 'white',
      }"
    >
      <ETST001_Table :data="nowPageItem" />
    </div>
  </Layout>
</template>

<script setup>
import { useStore } from "vuex";
import { ref, unref, computed, reactive, watch, toRefs, onMounted } from "vue";
import { useRoute, useRouter } from "vue-router";
import { useI18n } from "vue-i18n";
import axios from "@/axios";
import {
  VALIDATIONS,
  useState,
  getDateFormat,
  jsonToExcel,
  ElNotification,
} from "@/utils";
import ETST001_Table from "./ETST001_Table.vue";

import moment from "moment";

const props = defineProps(["isOpen", "siteData"]);
const { t } = useI18n();
const store = useStore();
const router = useRouter();

const ENT = computed(() => {
  return store?.state?.global?.ENT || "";
});

const nowPageItem = computed(() => {
  return list?.value?.[nowPage?.value - 1] || {};
});

const formRef = ref();

const [list, setList] = useState([]);
const [nowPage, setNowPage] = useState(1);

let [form, setForm] = useState({
  OOAGSTUS: "Y",
});
const rules = reactive({
  // ETSB001: [VALIDATIONS.isEmpty()],
});

onMounted(() => {
  getList();
});

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

async function onSearch() {
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

async function onClean() {
  setForm({});
  getList();
}

async function getList() {
  store.commit("global/setIsLoading", true);
  try {
    const res = await axios({
      url: `/ets/etst001_get01`,
      method: "post",
      data: {
        ENT: ENT.value,
        ...form.value,
      },
    });
    if (res?.data?.length) {
      setList(res?.data);
    } else {
      setList([]);
      ElNotification({
        title: "Error",
        message: "查無資料",
        type: "error",
      });
    }
  } catch (e) {
    console.log(e);
    setList([]);
  }
  store.commit("global/setIsLoading", false);
}

function onPrint(rowData) {
  // console.log("form.value >>>", form.value);
  const win = window.open(`/#/ETST001_PDF`, "", "height=400,width=800");
  win.data = rowData;
}

/**
 * pure front export excel
 */
function onExportExcel() {
  jsonToExcel(list.value);
}
</script>
