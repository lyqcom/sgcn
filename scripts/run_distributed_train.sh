#!/bin/bash

#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# ============================================================================

if [[ $# -gt 5 ]]; then
    echo "Usage: bash ./scripts/run_distributed_train.sh [RANK_TABLE] [RANK_SIZE] [DEVICE_START] [DATA_PATH] [DISTRIBUTED]"
exit 1
fi

ulimit -u unlimited
export RANK_SIZE=$2
DISTRIBUTED=$5
RANK_TABLE_FILE=$(realpath $1)
DATA_PATH=$(realpath $4)
export RANK_TABLE_FILE
echo "RANK_TABLE_FILE=${RANK_TABLE_FILE}"
echo "DATA_PATH=${DATA_PATH}"

device_start=$3
for((i=0; i<${RANK_SIZE}; i++))
do
    export DEVICE_ID=$((device_start + i))
    export RANK_ID=$i
    rm -rf ./device$i
    mkdir ./device$i
    cp -r ./src ./device$i
    cp ./train.py ./device$i
    echo "Start training for rank $RANK_ID, device $DEVICE_ID"
    cd ./device$i
    env > env.log
    nohup python train.py --device_id=$DEVICE_ID --edge-path=$DATA_PATH --distributed=$DISTRIBUTED > train.log 2>&1 &
    cd ..
done
