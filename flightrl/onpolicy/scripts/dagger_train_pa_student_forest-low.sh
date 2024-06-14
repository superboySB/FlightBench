#! /usr/bin/bash
##### use this for training
python ./dagger_train_perception_aware.py \
    --n_rollout_threads 1 \
    --n_training_threads 1 \
    --num_mini_batch 1 \
    --algorithm_name mappo \
    --episode_length 185 \
    --stage_two_episode_length 185 \
    --env_name LearningPA \
    --experiment_name forest-low \
    --use_recurrent_policy \
    --mlp_hidden_size 256 \
    --layer_N 1 \
    --log_interval 2 \
    --save_interval 20 \
    --num_env_steps 600000 \
    --ppo_epoch 6 \
    --max_grad_norm 8.0 \
    --seed 1 \
    --device cuda:0 \
    --scene_path scene/forest-low \
    --vec_env_config flightlib/configs/vec_env.yaml \
    --env_config flightlib/configs/quadrotor_env.yaml \
    --dyn_config flightlib/configs/dyn_param.yaml \
    --gate_radius 0.6 \
    --user_name ysa \
    --wandb_name yushuang20010911 \
    --gate_num 1 \
    --gate0_x 14.0 \
    --gate0_y 14.0 \
    --gate0_z 2.0 \
    --gate0_angle 45 \
    --model_dir /home/ysa/workspace/flightmare_ws/src/flightmare/flightrl/runs/LearningPA/mappo/forest-low-pa/wandb/run-20240418_192011-zhu49jpk/files \
    --pretrain_dir /home/ysa/workspace/flightmare_ws/src/flightmare/flightrl/onpolicy/runner/PAnet.pt \
    --data_dir /home/ysa/workspace/flightmare_ws/src/flightmare/flightrl/onpolicy/data \
    --eval_dir /home/ysa/workspace/flightmare_ws/src/flightmare/flightrl/onpolicy/eval \
    --use_unity \
    --scene_id 0