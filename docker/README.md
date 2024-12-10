Baseline Docker部署
```sh
docker build -f docker/simulation.dockerfile -t flightbench_image:sim --network=host --progress=plain .

docker run --name flightbench-sim -itd --privileged --gpus all --network=host \
    -v /tmp/.X11-unix:/tmp/.X11-unix:ro \
    -e DISPLAY=$DISPLAY \
    -e LOCAL_USER_ID="$(id -u)" \
    flightbench_image:sim /bin/bash

docker exec -it flightbench-sim /bin/bash
```