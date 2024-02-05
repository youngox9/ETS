<template>
  <Layout :auth="true">
    <teleport to="#portal-target">
      <h2>{{ $t("title_ETST004") }}</h2>
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
            <el-form-item :label="$t('ETSC001')" prop="ETSC001">
              <el-input
                :placeholder="$t('ETSC001')"
                type="text"
                v-model="form.ETSC001"
              >
              </el-input>
            </el-form-item>
          </el-col>
          <el-col :xs="24" :sm="4">
            <el-form-item :label="$t('ETSC002')" prop="ETSC002">
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
              </Autocomplete>
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
    <el-divider />
    <!-- 下方表格 -->
    <TableWithPagination ref="pageRef" :onChange="getList" :list="list">
      <template v-slot:controls>
        <el-upload
          action=""
          v-model="file"
          :multiple="false"
          :before-upload="onUpload"
          :show-file-list="false"
          :auto-upload="true"
        >
          <el-button ref="buttonRef" type="success" plain>
            {{ $t("upload") }}
            <el-icon class="el-icon--right"><Upload></Upload></el-icon>
          </el-button>
        </el-upload>
        <el-button
          plain
          type="warning"
          @click="onExportExcel"
          :disabled="!list?.length"
        >
          {{ $t("export") }}
          <el-icon class="el-icon--right">
            <Download />
          </el-icon>
        </el-button>
        <el-button type="primary" @click="onAdd">
          {{ $t("add") }}
          <el-icon class="el-icon--right">
            <Plus />
          </el-icon>
        </el-button>
      </template>
      <el-table :data="list" :style="{ margin: '20px 0' }">
        <el-table-column
          label="操作"
          align="center"
          fixed="right"
          :width="120"
          v-if="list.length"
        >
          <template #default="scope">
            <el-tooltip :content="$t('edit')" placement="top">
              <el-button type="primary" circle plain @click="onEdit(scope.row)">
                <el-icon>
                  <Edit />
                </el-icon>
              </el-button>
            </el-tooltip>
            <el-tooltip :content="$t('delete')" placement="top" v-if="isAdmin">
              <el-button
                type="danger"
                circle
                plain
                @click="onDelete(scope.row)"
              >
                <el-icon>
                  <Delete />
                </el-icon>
              </el-button>
            </el-tooltip>
          </template>
        </el-table-column>

        <el-table-column
          v-for="(k, index) in columns"
          :prop="k"
          :label="$t(k)"
          align="center"
          :width="120"
        />
      </el-table>
    </TableWithPagination>
  </Layout>
  <Modal v-model="modalConfig" :onChange="getList" />
</template>

<script setup>
import { useStore } from "vuex";
import { ref, unref, computed, reactive, watch, toRefs, onMounted } from "vue";
import { ElMessageBox } from "element-plus";
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
import moment from "moment";

import FileSaver from "file-saver";
import Modal from "./Modal.vue";

const [columns, setColumns] = useState([]);
const [modalConfig, setModalConfig] = useState({ isOpen: false });
const props = defineProps(["isOpen", "siteData"]);
const { t } = useI18n();
const store = useStore();
const router = useRouter();

const ENT = computed(() => store?.state?.global?.ENT || "");

const formRef = ref();
const pageRef = ref();
const [list, setList] = useState([]);

let [form, setForm] = useState({
  OOAGSTUS: "Y",
});
const rules = reactive({
  // ETSA001: VALIDATIONS.isEmpty(),
});
const profile = computed(() => {
  return store?.state?.global?.profile || {};
});

const isAdmin = computed(() => {
  const role_id = store?.state?.global?.profile?.role_id;
  return role_id === 1 || role_id === 22;
});

onMounted(() => {
  //getList();
});

watch(
  () => pageRef?.value,
  (val) => {
    //if (val) getList();
  }
);

watch(
  () => list?.value,
  (val) => {
    const first = val?.[0] || {};
    const temp = Object.keys(first);
    setColumns(temp);
  },
  { deep: true }
);

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
    const { page: currentPage = 1, pageSize = 10 } =
      pageRef?.value?.pageConfig || {};
    const setPageConfig = pageRef?.value?.setPageConfig;

    const res = await axios({
      url: `/ets/etsc_get02`,
      method: "post",
      data: {
        ENT: ENT.value,
        PAGE: currentPage,
        PAGENUM: pageSize,
        ...form.value,
      },
    });
    const { result = [], total, page } = res?.data || {};
    setPageConfig({ total, page });
    if (result.length) {
      setList(result);
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

/**
 * insert
 */
function onAdd() {
  setModalConfig({ ...modalConfig.value, isOpen: true, mode: "add", data: {} });
}

/**
 * delete
 */
async function onDelete(rowData) {
  try {
    await ElMessageBox.confirm(`${t("confirm_delete")}?`, t("warning"), {
      confirmButtonText: t("submit"),
      cancelButtonText: t("cancel"),
      type: "warning",
    });
    store.commit("global/setIsLoading", true);
    try {
      const res = await axios({
        url: `/ets/etsc_del01`,
        method: "post",
        data: {
          ENT: ENT.value,
          SITE: "0001",
          ...rowData,
        },
      });
      await getList();
    } catch (e) {
      console.log(e);
    }
  } catch (e) {}

  store.commit("global/setIsLoading", false);
}

/**
 * edit
 */
function onEdit(rowData) {
  setModalConfig({
    ...modalConfig.value,
    isOpen: true,
    mode: "edit",
    data: rowData,
  });
}

/**
 * upload
 */
async function onUpload(file) {
  console.log(file);
  store.commit("global/setIsLoading", true);
  const formData = new FormData();
  formData.append("upload", file);
  formData.append("USERID", profile.value.username);
  formData.append("ENT", ENT.value);
  try {
    const res = await axios({
      url: `/ets/etsc_upload01`,
      method: "post",
      data: formData,
    });

    const result = res?.data || [];
    ElNotification({
      title: t("success"),
      message: "上傳成功",
      type: "success",
    });
  } catch (e) {
    console.log(e);
  }
  store.commit("global/setIsLoading", false);
}

/**
 * pure front export excel
 */
function onExportExcel() {
  jsonToExcel(list.value);
}
</script>
