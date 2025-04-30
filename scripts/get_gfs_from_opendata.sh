#!/usr/bin/env bash
set -euo pipefail

# 本脚本下载最近一次 GFS 分析场（f000）GRIB2 文件，且留 6 小时裕量

OUTDIR="./gfs_with_6h_margin"
mkdir -p "$OUTDIR"

# 获取当前 UTC 时间，减去 6 小时，确保裕量
ADJUSTED_TIME=$(date -u -d '6 hours ago' +'%Y%m%d %H')
UTC_DATE=${ADJUSTED_TIME%% *}
UTC_HOUR=${ADJUSTED_TIME##* }

# GFS 模型周期：00, 06, 12, 18
CYCLES=(18 12 06 00)
SELECT_CYCLE=""
for c in "${CYCLES[@]}"; do
  if ((10#$UTC_HOUR >= c)); then
    printf -v SELECT_CYCLE "%02d" "$c"
    break
  fi
done

# 若减 6h 后还未到当日首班（00），回滚到前一天 18UTC
if [[ -z "$SELECT_CYCLE" ]]; then
  UTC_DATE=$(date -u -d "${UTC_DATE} 00:00 UTC -1 day" +%Y%m%d)
  SELECT_CYCLE="18"
fi

echo "调整后 UTC 日期: $UTC_DATE, 选择 GFS 周期: ${SELECT_CYCLE}UTC (含6h裕量)"

S3_BUCKET="s3://noaa-gfs-bdp-pds"
S3_KEY_PREFIX="gfs.${UTC_DATE}/${SELECT_CYCLE}/atmos"

retries=2
for i in $(seq -f "%03g"  0 3 384)
do
    for j in $(seq 1 $retries); do
        FILENAME="gfs.t${SELECT_CYCLE}z.pgrb2.0p25.f$i"
        LOCAL_PATH="${OUTDIR}/${FILENAME}"
        echo "下载：${S3_BUCKET}/${S3_KEY_PREFIX}/${FILENAME} 到 $LOCAL_PATH"
        aws s3 cp "${S3_BUCKET}/${S3_KEY_PREFIX}/${FILENAME}" "$LOCAL_PATH" --no-progress --no-sign-request
        echo "完成，文件位于：$LOCAL_PATH"
        # Check if the download was successful
        if [ $? -eq 0 ]; then
            echo "Download successful"
            break
        else
            echo "Download failed, retrying..."
        fi
    done
done
