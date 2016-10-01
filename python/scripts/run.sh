docker build -t chriscohoat/aquaponics .
docker rm -v --force `docker ps -qa`
docker run -it -p 9999:9999 --name aquaponics --privileged -d -v /dev:/dev chriscohoat/aquaponics
docker logs -f aquaponics
