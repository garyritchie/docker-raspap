# makefile

raspap: .build
	touch /etc/dnsmasq.conf
## volume-mount all the networking things
	-@docker rm -f $@ > /dev/null
	docker run -d \
		--restart=always \
		--net="host" \
		--privileged \
		--name $@ \
		-p 80:80 \
		-v /etc/network/interfaces:/etc/network/interfaces \
		-v /etc/hosts:/etc/hosts \
		-v /etc/dnsmasq.conf:/etc/dnsmasq.conf \
		-v /etc/wpa_supplicant:/etc/wpa_supplicant \
		raspap

build: .build

.build: Dockerfile
	docker build --rm=true -t raspap .
	@docker inspect -f '{{.Id}}' raspap > .build

clean: 
	docker rm -f raspap

.PHONY: clean
