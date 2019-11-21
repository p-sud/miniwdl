#!/bin/bash
# run the HCA skylab bulk RNA pipeline test
set -eo pipefail

cd "$(dirname $0)/../.."
SOURCE_DIR="$(pwd)"

DN=$(mktemp -d --tmpdir miniwdl_runner_tests_XXXXXX)
cd $DN
echo "$DN"

export PYTHONPATH="$SOURCE_DIR:$PYTHONPATH"
miniwdl="python3 -m WDL"

git clone --depth 1 https://github.com/ENCODE-DCC/atac-seq-pipeline.git
wget https://storage.googleapis.com/encode-pipeline-test-samples/encode-atac-seq-pipeline/ENCSR356KRQ_subsampled_caper.json

BASH_TAP_ROOT="$SOURCE_DIR/tests/bash-tap"
source $SOURCE_DIR/tests/bash-tap/bash-tap-bootstrap
plan tests 1
set +e

$miniwdl run atac-seq-pipeline/atac.wdl --no-quant-check --verbose \
    -i ENCSR356KRQ_subsampled_caper.json \
    --verbose --runtime-defaults '{"docker":"quay.io/encode-dcc/atac-seq-pipeline:v1.5.4"}' --runtime-memory-max 4G --runtime-cpu-max 2
is "$?" "0" "pipeline success"
