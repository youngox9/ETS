<template>
  <div v-if="!data?.etsb?.[0]" />
  <div v-else class="table-div">
    <!-- etsb -->
    <table>
      <tr>
        <td width="120" rowspan="2">{{ $t("ETSB001") }}</td>
        <td rowspan="2">{{ data?.etsb?.[0]?.ETSB001 }}</td>
        <td width="120" rowspan="2">{{ $t("ETSB003") }}</td>
        <td rowspan="2">{{ data?.etsb?.[0]?.ETSB003 }}</td>
        <td width="120">{{ $t("ETSB005") }}</td>
        <td>{{ data?.etsb?.[0]?.ETSB005 }}</td>
      </tr>
      <tr>
        <td>{{ $t("ETSB006") }}</td>
        <td>{{ data?.etsb?.[0]?.ETSB006 }}</td>
      </tr>
      <tr>
        <!-- 姓名 -->
        <td>{{ $t("ETSB002") }}</td>
        <td>{{ data?.etsb?.[0]?.ETSB002 }}</td>
        <!-- 工作年資 -->
        <td>{{ $t("ETSB004") }}</td>
        <td>{{ diffInYears }}年</td>
        <!-- 性別 -->
        <td>{{ $t("ETSB007") }}</td>
        <td>
          男 {{ data?.etsb?.[0]?.ETSB007 === "M" ? "☑" : "☐" }} 女
          {{ data?.etsb?.[0]?.ETSB007 === "F" ? "☑" : "☐" }}
        </td>
      </tr>
    </table>
    <!-- etsc -->
    <table>
      <tr>
        <td width="60" rowspan="4">職<br />務<br />異<br />動</td>
        <td>單位別</td>
        <td>職務名稱</td>
        <td>期間</td>
      </tr>
      <tr v-for="(item, index) in data.etsc">
        <td>{{ item.OOEFL003 }}</td>
        <td>{{ item.OOCQL004 }}</td>
        <td>{{ item.ETSC004 }}</td>
      </tr>
    </table>
    <table>
      <tr>
        <td colspan="6">訓練紀錄</td>
      </tr>
      <tr>
        <td>日期</td>
        <td>課程名稱</td>
        <td>訓練單位</td>
        <td>時數</td>
        <td>證照管理</td>
        <td>登錄人員</td>
      </tr>
      <tr v-for="(item, index) in data?.etsd">
        <td>{{ item[0] }}</td>
        <td>{{ item[1] }}</td>
        <td>{{ item[2] }}</td>
        <td>{{ item[3] }}</td>
        <td>{{ item[4] }}</td>
        <td>{{ item[5] }}</td>
      </tr>
    </table>
  </div>
</template>

<script setup>
import _ from "lodash";
import { v4 as uuidv4 } from "uuid";
import { useStore } from "vuex";
import {
  ref,
  unref,
  computed,
  reactive,
  watch,
  toRefs,
  onMounted,
  onBeforeMount,
  nextTick,
} from "vue";

import { useRoute, useRouter } from "vue-router";
import { useI18n } from "vue-i18n";
import axiosGlobal from "axios";
import axios from "@/axios";
import { VALIDATIONS, useState, printPage, saveExcel } from "@/utils";
import moment from "moment";

const props = defineProps(["data"]);
const { t } = useI18n();
const store = useStore();
const router = useRouter();
const route = useRoute();

const profile = computed(() => store?.state?.global?.profile || {});
// const [data, setData] = useState({});

const ENT = computed(() => {
  return store?.state?.global?.ENT || "";
});

onBeforeMount(() => {
  // getData();
});

const diffInYears = computed(() => {
  const day1 = props?.data?.etsb?.[0]?.ETSB005;
  if (day1) {
    const date1 = moment(day1);
    const date2 = moment(new Date());
    const diffInYears = date2.diff(date1, "years");
    return diffInYears;
  }
});
</script>

<style lang="scss" scoped>
.table-div {
  display: block;
  width: 1600px;
  max-width: 100%;
  margin: 0 auto;
  position: relative;
  /* padding-bottom: 24px; */

  h3 {
    padding: 6px 0;
  }

  p {
    margin: 12px 0;
  }

  table {
    width: 100%;
    table-layout: fixed;
    border: 2px solid black;

    margin-bottom: -2px;
    /* &:not(:last-child) {
      border-bottom: none;
    } */

    th,
    td {
      text-align: center;
      line-height: 1;
      padding: 4px 0;
      word-break: break-all;
      border: 2px solid black;
      border-bottom: none;
      align-items: center;
      /* border: 1px solid red; */
      font-size: 16px;
      vertical-align: middle;
    }
    th {
      font-weight: bolder;
    }
  }
}
</style>
