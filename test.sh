#!/bin/sh

set -e

# Rebuild the Docker image for this step.
./build.sh

# Download some sample data.
mkdir -p sample_data
if [ ! -f "sample_data/AS20-minimal3.zip" ]; then
    wget https://storage.googleapis.com/tripledip-geffenlab/AS20-minimal3.zip -O sample_data/AS20-minimal3.zip
    unzip sample_data/AS20-minimal3.zip -d sample_data
fi

# Add a custom probe settings JSON.
cp imec0-sample-kilosort4-settings.json sample_data

# Run Kilosort 4 with sample data, in a Docker container.
mkdir -p $PWD/results
docker run --rm \
  --user $(id -u):$(id -g) \
  --volume $PWD/results:$PWD/results \
  --volume $PWD/sample_data:$PWD/sample_data \
  --workdir $PWD/sample_data \
  ghcr.io/geffenlab/geffenlab-kilosort4:local \
  --input-dir $PWD/sample_data/AS20-minimal3/03112025/ecephys \
  --results-dir $PWD/results

# Expect several files produced.
ls results/AS20_03112025_trainingSingle6Tone2024_Snk3.1_g0/AS20_03112025_trainingSingle6Tone2024_Snk3.1_g0_imec0/AS20_03112025_trainingSingle6Tone2024_Snk3.1_g0_t0.imec0.ap.prb
ls results/AS20_03112025_trainingSingle6Tone2024_Snk3.1_g0/AS20_03112025_trainingSingle6Tone2024_Snk3.1_g0_imec0/imec0-kilosort4-effective-settings.json
ls results/AS20_03112025_trainingSingle6Tone2024_Snk3.1_g0/AS20_03112025_trainingSingle6Tone2024_Snk3.1_g0_imec0/kilosort4.log
ls results/AS20_03112025_trainingSingle6Tone2024_Snk3.1_g0/AS20_03112025_trainingSingle6Tone2024_Snk3.1_g0_imec0/params.py
