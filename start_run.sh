#!/bin/bash

N=2  # number of jobs you want to launch

BASE_JOBID="imagenet"

REPO_DIR="/rds/general/user/mm3218/home/git/diffusion-posterior-sampling"
SAVE_DIR="/rds/general/user/mm3218/home/projects/2026/dps_sbc/${BASE_JOBID}"

data_config=$REPO_DIR/configs/imagenet_data_config.yaml
model_config=$REPO_DIR/configs/imagenet_model_config.yaml
diffusion_config=$REPO_DIR/configs/diffusion_config.yaml
task_config=$REPO_DIR/configs/inpainting_config.yaml

mkdir -p $SAVE_DIR

TEMPLATE_FILE="run_template.pbs"

for i in $(seq 1 $N); do
    
    mkdir -p pbs_jobs
    job_dir=${SAVE_DIR}/run_${i}
    job_script="${job_dir}/run_${i}.pbs"
    mkdir -p $job_dir

    cat > $job_script <<EOF
#!/bin/sh
#PBS -N dps_${BASE_JOBID}_${i}
#PBS -l walltime=72:00:00
#PBS -l select=1:ncpus=1:mem=100gb:ngpus=1
#PBS -j oe

source /rds/general/user/mm3218/home/miniforge3/etc/profile.d/conda.sh
conda activate DPS

REPO_DIR="$REPO_DIR"
data_config="$data_config"
model_config="$model_config"
diffusion_config="$diffusion_config"
task_config="$task_config"

save_dir="$job_dir"

cd \$REPO_DIR
python3 \$REPO_DIR/sample_condition.py \\
  --data_config=\$data_config \\
  --model_config=\$model_config \\
  --diffusion_config=\$diffusion_config \\
  --task_config=\$task_config \\
  --gpu=0 \\
  --save_dir=\$save_dir
EOF

    chmod +x $job_script
    cd $job_dir
    qsub $job_script

    echo "Submitted job $jobid"

done
