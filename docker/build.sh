cp ./requirements.txt docker/requirements.txt
cd docker

docker build -t chbricout/monarch-circuits .
docker push chbricout/monarch-circuits

rm requirements.txt

