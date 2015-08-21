# makefile

raspap: .build
	-@docker rm -f $@ > /dev/null
	docker run -d \
		--name $@ \
		-p 80:80 \
		--net=host \
		raspap

build: .build

.build: Dockerfile
	docker build --rm=true -t raspap .
	@docker inspect -f '{{.Id}}' raspap > .build

clean: 
	docker rm -f raspap

.PHONY: clean