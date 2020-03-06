# Copyright (C) 2020 by the Georgia Tech Research Institute (GTRI)
# This software may be modified and distributed under the terms of
# the BSD 3-Clause license. See the LICENSE file for details.

.PHONY: help

APP_NAME ?= `grep 'app:' mix.exs | sed -e 's/\[//g' -e 's/ //g' -e 's/app://' -e 's/[:,]//g'`
APP_VSN ?= `grep 'version:' mix.exs | cut -d '"' -f2`
BUILD ?= `git rev-parse --short HEAD`

ifeq ($(ORG),)
ORG := "kitplummer"
endif

help:
	@echo "$(APP_NAME):$(APP_VSN)-$(BUILD)"
	@perl -nle'print $& if m{^[a-zA-Z_-]+:.*?## .*$$}' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

build: ## Build the Docker image
	docker build --build-arg APP_NAME=$(APP_NAME) \
  --build-arg APP_VSN=$(APP_VSN) \
  -t $(ORG)/$(APP_NAME):$(APP_VSN)-$(BUILD) \
  -t $(ORG)/$(APP_NAME):latest .

build-release: ## Build the release Docker image
	docker build --build-arg APP_NAME=$(APP_NAME) \
  --build-arg APP_VSN=$(APP_VSN) \
  -t $(ORG)/$(APP_NAME):$(APP_VSN) \
  -t $(ORG)/$(APP_NAME):latest .

run: ## Run the app in Docker
	docker run \
	-e LEI_CRITICAL_CONTRIBUTOR_LEVEL=1 \
  --expose 4444 -p 4444:4444 \
  --rm -d $(ORG)/$(APP_NAME):latest

publish-snapshot: ## Push the artifact out
	echo $(DOCKER_PASSWORD) | docker login -u $(DOCKER_USERNAME) --password-stdin
	docker push $(ORG)/$(APP_NAME):$(APP_VSN)-$(BUILD)
	docker push $(ORG)/$(APP_NAME):latest

publish-release: ## Push the artifact out
	echo $(DOCKER_PASSWORD) | docker login -u $(DOCKER_USERNAME) --password-stdin
	docker push $(ORG)/$(APP_NAME):$(APP_VSN)
	docker push $(ORG)/$(APP_NAME):latest