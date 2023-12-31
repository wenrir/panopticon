PROJECT_DIR := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
SHELL := /bin/sh
.DEFAULT_GOAL := help
args=$(filter-out $@,$(MAKECMDGOALS))
compose := docker compose --file $(PROJECT_DIR)/docker-compose.yml
SBLINT-exists: ; @which sblint > /dev/null 2>&1

.PHONY: setup
## Setup development enviroment.
setup:
	@git config --local core.hookPath .githooks
	$(MAKE) build

.PHONY: start
## Start docker services
## Run specific command inside modules, example usage `make start ui`
start:
	@$(compose) up $(args) --detach

.PHONY: stop
## Stop docker services
stop:
	@docker compose down --rmi all --volumes --remove-orphans

.PHONY: cmd
## Run specific command inside modules, example usage `make cmd ui sh`
cmd:
	@$(compose) run --rm $(args)

.PHONY: sblint
## Run cl linter
sblint: SBLINT-exists
	@sblint | reviewdog -efm="%f:%l:%c: %m" -diff="git diff main"


.PHONY: build
## Build all docker images
dbuild:
	@$(compose) build

.PHONY: clean
## Clean images
dclean:
	@$(compose) images -q | xargs -r docker rmi

.PHONY: g-update
## Pull origin master and update submodules
g-update:
	git pull origin master
	git submodule update --init --recursive

.PHONY: g-update-all
## Update repository (and submodules) against respective master
g-update-all: update
	git submodule foreach git pull origin master
	git submodule foreach git checkout master

.PHONY: test_sample
## Run test for sample module
test_sample:
	@docker compose --file $(PROJECT_DIR)/docker-compose.test.yml run --rm --quiet-pull test-sample; \
	docker compose --file $(PROJECT_DIR)/docker-compose.test.yml down --rmi all --volumes --remove-orphans

.PHONY: test
## Run tests for all modules
test: test_sample

.PHONY: build_sample
## Builds sample module
build_sample:
	@MODULE_NAME=sample $(compose) build module

.PHONY: build
## Builds all modules
build: build_sample

.PHONY: help
help:
	@echo "$$(tput setaf 2)Make rules:$$(tput sgr0)";sed -ne"/^## /{h;s/.*//;:d" -e"H;n;s/^## /---/;td" -e"s/:.*//;G;s/\\n## /===/;s/\\n//g;p;}" ${MAKEFILE_LIST}|awk -F === -v n=$$(tput cols) -v i=4 -v a="$$(tput setaf 6)" -v z="$$(tput sgr0)" '{printf"- %s%s%s\n",a,$$1,z;m=split($$2,w,"---");l=n-i;for(j=1;j<=m;j++){l-=length(w[j])+1;if(l<= 0){l=n-i-length(w[j])-1;}printf"%*s%s\n",-i," ",w[j];}}'
