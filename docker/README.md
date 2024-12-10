Baseline Docker部署
```sh
docker build -f docker/simulation.dockerfile -t sbdrone_image:sim --network=host --progress=plain .
```