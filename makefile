# makefile

raspap: .build
	file=/etc/dnsmasq.conf

	if [ ! -e "${file}" ] ; then
	    touch "${file}"
	fi

	if [ ! -w "${file}" ] ; then
	    echo cannot write to ${file}
	    exit 1
	fi
## volume-mount all the networking things
	-@docker rm -f $@ > /dev/null
	docker run -d \
		--privileged \
		--name $@ \
		-p 80:80 \
		--net=host \
		-v /etc/network/interfaces:/etc/network/interfaces \
		-v /etc/hosts:/etc/hosts \
		-v /etc/dnsmasq.conf:/etc/dnsmasq.conf \
		raspap

build: .build

.build: Dockerfile
	docker build --rm=true -t raspap .
	@docker inspect -f '{{.Id}}' raspap > .build

clean: 
	docker rm -f raspap

.PHONY: clean