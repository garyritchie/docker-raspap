# makefile

raspap: .build
## volume-mount all the networking things
	-@docker rm -f $@ > /dev/null
	docker run -d \
		--name $@ \
		-p 80:80 \
		--net=host \
		-v /etc/network/interfaces \
		-v /etc/hosts \
		-v /etc/dnsmasq.conf \
		raspap

build: .build

.build: Dockerfile
	docker build --rm=true -t raspap .
	@docker inspect -f '{{.Id}}' raspap > .build

clean: 
	docker rm -f raspap

.PHONY: clean