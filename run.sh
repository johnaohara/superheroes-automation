#!/bin/bash

# Run qdup scripts easily such that you don't have to care about which config files to provide

# Path to search for folders
CWD="$(dirname "$0")"
BASE_BENCHMARKS_FOLDER="${CWD}/benchmarks"
BASE_MODES_FOLDER="${CWD}/modes"

# Check if the correct number of arguments is provided
if [ "$#" -lt 2 ] || [ "$#" -gt 4 ]; then
  echo "Usage: $0 <native|jvm> <benchmark_folder> [local|remote] [benchmark_params]"
  exit 1
fi

# Validate image mode
MODE="$1"
if [ ! -f "$BASE_MODES_FOLDER/$MODE.script.yaml" ]; then
  echo "Error: Script file '$MODE.script.yaml' does not exist in $BASE_MODES_FOLDER."
  echo "Available modes are:"
  ls -1 $BASE_MODES_FOLDER/*.script.yaml
  exit 1
fi

# Validate benchmark
BENCHMARK_FOLDER="$2"
if [ ! -d "$BASE_BENCHMARKS_FOLDER/$BENCHMARK_FOLDER" ]; then
  echo "Error: Benchmark folder '$BENCHMARK_FOLDER' does not exist in $BASE_BENCHMARKS_FOLDER."
  echo "Available benchmarks are:"
  ls -1 $BASE_BENCHMARKS_FOLDER
  exit 1
fi

# Validate
if [ "$#" -ge 3 ]; then
  LOCATION="$3"
  if [[ "$LOCATION" != "local" && "$LOCATION" != "remote" ]]; then
    echo "Error: Server location, if provided, must be either 'local' or 'remote'."
    exit 1
  fi
else
  # default is 'local' 
  LOCATION="local"
fi

# handle additional HF benchmark params
if [ "$#" -eq 4 ]; then
  BENCHMARK_PARAMS="$4"
  HF_BENCHMARK_PARAMS="-S HF_BENCHMARK_PARAMS='$BENCHMARK_PARAMS'"
else
  HF_BENCHMARK_PARAMS=""
fi

echo Running benchmark with the following configuration:
echo "  > Mode:             $MODE"
echo "  > Benchmark:        $BENCHMARK_FOLDER"
echo "  > Server:           $LOCATION"
echo "  > Benchmark params: $BENCHMARK_PARAMS"

QDUP_CMD="jbang qDup@hyperfoil util.yaml ${BASE_BENCHMARKS_FOLDER}/${BENCHMARK_FOLDER}/${BENCHMARK_FOLDER}.env.yaml envs/${LOCATION}.env.yaml modes/${MODE}.script.yaml hyperfoil.yaml superheroes.yaml qdup.yaml $HF_BENCHMARK_PARAMS"

echo Executing: "$QDUP_CMD"

eval $QDUP_CMD