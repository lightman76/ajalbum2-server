
docker run --platform linux/amd64 --net ajalbum2-server_default -it --env-file .env -v /home/other/photos/pics/unlabeled:/new-photos -v ajalbum2-server_photo-storage:/opt/photo-storage -v $PWD:/opt/app ajalbum-server-toolbox

