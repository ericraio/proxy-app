PROJECT           ?= proxyapp-proxy
TAG               ?= latest
PROXY             ?= proxy
STAGE             ?= production
PROXY_DEPLOYMENT  ?= $(PROXY)-$(STAGE)
REGISTRY          ?= gcr.io/rich-city-274720
IMAGE              = $(REGISTRY)/$(PROJECT):$(TAG)

.PHONY: all
all:
	@echo "Available targets:"
	@echo "  * build          - build a Docker image on Google Cloud for $(IMAGE)"
	@echo "  * build-local    - build a Docker image for $(IMAGE)"
	@echo "  * pull           - pull down previous docker builds of $(IMAGE)"
	@echo "  * push           - push $(IMAGE) to remote registry"
	@echo "  * apply          - apply proxy kubernetes configuration to GKE"
	@echo "  * rollout        - rollout new changes for $(PROXY_DEPLOYMENT)"
	@echo "  * rollback       - rollback latest changes for $(PROXY_DEPLOYMENT)"
	@echo "  * watch          - watch pod changes"
	@echo "  * db-migrate     - migrate new database changes"

.PHONY: build
build:
	gcloud builds submit .;

.PHONY: build-local
build-local:
	docker build -t $(IMAGE) .;

.PHONY: pull
pull:
	docker pull $(IMAGE) || true;

.PHONY: push
push:
	docker push $(IMAGE);

.PHONY: apply
apply:
	git checkout master; \
	kubectl apply -f ../deploy/proxy.yml;

.PHONY: rollout
rollout:
	kubectl patch deployment $(PROXY_DEPLOYMENT) \
		-p "{\"spec\":{\"template\":{\"metadata\":{\"labels\":{\"date\":\"`date +'%s'`\"}}}}}"; \

.PHONY: watch
watch:
	kubectl get pods -w -o wide;

.PHONY: rollback
rollback:
	kubectl rollout undo deployment/$(PROXY_DEPLOYMENT);
