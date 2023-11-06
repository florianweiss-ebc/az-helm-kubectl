default: docker_build
include .env

# Note:
#   Latest version of azure cli may be found at: https://github.com/Azure/azure-cli/releases
#	Latest version of kubectl may be found at: https://github.com/kubernetes/kubernetes/releases
# 	Latest version of helm may be found at: https://github.com/kubernetes/helm/releases
# 	Latest version of yq may be found at: https://github.com/mikefarah/yq/releases
VARS:=$(shell sed -ne 's/ *\#.*$$//; /./ s/=.*$$// p' .env )
$(foreach v,$(VARS),$(eval $(shell echo export $(v)="$($(v))")))
DOCKER_IMAGE ?= florianweiss/az-helm-kubectl
#DOCKER_TAG ?= `git rev-parse --abbrev-ref HEAD`
DOCKER_TAG ?= $(KUBE_VERSION)

docker_build:
	@docker buildx build \
	  --build-arg AZ_VERSION=$(AZ_VERSION) \
	  --build-arg KUBE_VERSION=$(KUBE_VERSION) \
	  --build-arg HELM_VERSION=$(HELM_VERSION) \
	  --build-arg YQ_VERSION=$(YQ_VERSION) \
	  -t $(DOCKER_IMAGE):$(DOCKER_TAG) .

docker_push:
	# Push to DockerHub
	docker tag $(DOCKER_IMAGE):$(DOCKER_TAG) $(DOCKER_IMAGE):latest
	docker push $(DOCKER_IMAGE):$(DOCKER_TAG)
	docker push $(DOCKER_IMAGE):latest
