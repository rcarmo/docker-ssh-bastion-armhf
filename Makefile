IMAGE_NAME=rcarmo/bastion:armhf
HOSTNAME=bastion
build: Dockerfile
	docker build -t ${IMAGE_NAME} .

shell:
	docker run --name ${HOSTNAME} -h ${HOSTNAME} \
	-v ${HOME}/.ssh/authorized_keys:/home/bastion/.ssh/authorized_keys:ro \
	-p 2211:2211 \
	-it ${IMAGE_NAME} /bin/sh

daemon:
	-docker kill ${HOSTNAME}
	-docker rm ${HOSTNAME}
	docker run --name ${HOSTNAME} -h ${HOSTNAME} \
	-d --restart=always \
	--cpu-period=50000 --cpu-quota=500 \
	--security-opt no-new-privileges \
	--memory 128M \
	--cap-drop ALL \
        --net=host \
        --cap-add SETGID --cap-add SETUID --cap-add SYS_CHROOT --cap-add KILL --cap-add SYS_TTY_CONFIG --cap-add CHOWN --cap-add MKNOD --cap-add FOWNER \
	-v ${HOME}/.ssh/authorized_keys:/home/bastion/.ssh/authorized_keys:ro \
	-p 2211:2211 -p 60000-61000:60000-61000/udp ${IMAGE_NAME}

push:
	docker push ${IMAGE_NAME}

clean:
	-docker rm -v $$(docker ps -a -q -f status=exited)
	-docker rmi $$(docker images -q -f dangling=true)
	-docker rmi $(IMAGE_NAME)
