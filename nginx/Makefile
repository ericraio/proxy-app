PROJECT           ?= proxyapp-nginx
TAG               ?= latest
NGINX             ?= nginx
WEB               ?= webapp
STAGE             ?= production
NGINX_DEPLOYMENT  ?= $(WEB)-$(STAGE)
REGISTRY          ?= gcr.io/proxy-app-274720
IMAGE              = $(REGISTRY)/$(PROJECT):$(TAG)

.PHONY: all
all:
	@echo "Available targets:"
	@echo "  * build          - build a Docker image on Google Cloud for $(IMAGE)"
	@echo "  * build-local    - build a Docker image for $(IMAGE)"
	@echo "  * pull           - pull down previous docker builds of $(IMAGE)"
	@echo "  * push           - push $(IMAGE) to remote registry"
	@echo "  * apply          - apply proxy kubernetes configuration to GKE"
	@echo "  * rollout        - rollout new changes for $(NGINX_DEPLOYMENT)"
	@echo "  * rollback       - rollback latest changes for $(NGINX_DEPLOYMENT)"
	@echo "  * watch          - watch pod changes"
	@echo "  * exec           - exec a command to the $(NGINX) pod - make exec /bin/bash"
	@echo "  * logs           - tail pod logs for $(NGINX)"
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
	kubectl apply -f ../deploy/deply.yml;

.PHONY: rollout
rollout:
	kubectl patch deployment $(NGINX_DEPLOYMENT) \
		-p "{\"spec\":{\"template\":{\"metadata\":{\"labels\":{\"date\":\"`date +'%s'`\"}}}}}"; \

.PHONY: watch
watch:
	kubectl get pods -w -o wide;

.PHONY: rollback
rollback:
	kubectl rollout undo deployment/$(NGINX_DEPLOYMENT);

.PHONY: exec
exec:
	kubectl exec -it $$(kubectl get pods | grep $(WEB) | awk '/$(WEB)/ { print $$1 }') -c $(NGINX) $(call args, );

.PHONY: logs
logs:
	kubectl logs $$(kubectl get pods | grep $(WEB) | awk '/$(WEB)/ { print $$1 }') $(NGINX) -f;
