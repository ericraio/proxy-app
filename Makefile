PROJECT           ?= proxyapp
TAG               ?= latest
WEB               ?= webapp
NGINX             ?= nginx
WORKER            ?= sidekiq
STAGE             ?= production
PROXY             ?= proxy
WEB_DEPLOYMENT    ?= $(WEB)-$(STAGE)
WORKER_DEPLOYMENT ?= $(WORKER)-$(STAGE)
PROXY_DEPLOYMENT  ?= $(PROXY)-$(STAGE)
REGISTRY          ?= gcr.io/rich-city-274720
IMAGE              = $(REGISTRY)/$(PROJECT):$(TAG)

args = `arg="$(filter-out $@,$(MAKECMDGOALS))" && echo $${arg:-${1}}`

.PHONY: all
all:
	@echo "Available targets:"
	@echo "  * build          - build a Docker image on Google Cloud for $(IMAGE)"
	@echo "  * docker-build   - build a Docker image for $(IMAGE)"
	@echo "  * deploy         - prepare, build, and deploy $(IMAGE) to GKE"
	@echo "  * pull           - pull down previous docker builds of $(IMAGE)"
	@echo "  * push           - push $(IMAGE) to remote registry"
	@echo "  * apply          - apply all kubernetes configuration to GKE"
	@echo "  * rollout        - rollout new changes for $(WEB_DEPLOYMENT) / $(WORKER_DEPLOYMENT)"
	@echo "  * rollout-worker - rollout new changes for $(WORKER_DEPLOYMENT)"
	@echo "  * rollout-proxy  - rollout new changes for $(PROXY_DEPLOYMENT)"
	@echo "  * rollback       - rollback latest changes for $(WEB_DEPLOYMENT) / $(WORKER_DEPLOYMENT)
	@echo "  * exec           - exec a command to the $(WEB) container - make exec /bin/bash"
	@echo "  * exec-nginx     - exec a command to the $(NGINX) container - make exec /bin/bash"
	@echo "  * exec-worker    - exec a command to the $(WORKER) container - make exec /bin/bash"
	@echo "  * logs           - tail pod logs for $(WEB)"
	@echo "  * logs-nginx     - tail pod logs for $(WEB) NGINX"
	@echo "  * logs-worker    - tail pod logs for $(WORKER)"
	@echo "  * logs-proxy     - tail pod logs for $(PROXY)"
	@echo "  * watch          - watch pod changes"
	@echo "  * status         - status of all the resources"
	@echo "  * db-migrate     - migrate new database changes"
	@echo "  * clean          - clean up unwanted pods"

.PHONY: build
build:
	version=$$(git rev-parse HEAD); \
    BABEL_ENV=production RAILS_ENV=production && \
    bundle exec rake webpacker:clobber && \
    bundle exec rails webpacker:compile && \
	git update-index --assume-unchanged cloudbuild.yaml; \
	sed -i '' "s/<VERSION>/$$version/g" cloudbuild.yaml; \
	gcloud builds submit --config cloudbuild.yaml .; \
	git update-index --no-assume-unchanged cloudbuild.yaml; \
	git checkout cloudbuild.yaml;

.PHONY: docker-build
docker-build:
	docker build -t $(IMAGE) .

.PHONY: deploy
deploy:
	version=$$(git rev-parse HEAD); \
	git branch -f master; \
	git pull origin master; \
	git update-index --assume-unchanged deploy/deploy.yml deploy/sidekiq.yml cloudbuild.yaml; \
	sed -i '' "s/<VERSION>/$$version/g" cloudbuild.yaml; \
	gcloud builds submit --config cloudbuild.yaml .; \
	sed -i '' "s/<VERSION>/$$version/g" deploy/deploy.yml; \
	sed -i '' "s/<VERSION>/$$version/g" deploy/sidekiq.yml; \
	kubectl apply -f ./deploy; \
	git update-index --no-assume-unchanged deploy/deploy.yml deploy/sidekiq.yml cloudbuild.yaml; \
	git checkout deploy/ cloudbuild.yaml;\

.PHONY: pull
pull:
	docker pull $(IMAGE) || true

.PHONY: push
push:
	docker push $(IMAGE)

.PHONY: apply
apply:
	sed -i '' "s/<VERSION>/latest/g" deploy/deploy.yml; \
	sed -i '' "s/<VERSION>/latest/g" deploy/sidekiq.yml; \
  kubectl apply -f ./deploy; \
  git checkout deploy/

.PHONY: apply-local
apply-local:
	sed -i '' "s/<VERSION>/$$(git rev-parse HEAD)/g" deploy/deploy.yml; \
	sed -i '' "s/<VERSION>/$$(git rev-parse HEAD)/g" deploy/sidekiq.yml; \
  kubectl apply -f ./deploy; \
  git checkout deploy/

.PHONY: rollout
rollout:
	sed -i '' "s/<VERSION>/latest/g" deploy/deploy.yml; \
	sed -i '' "s/<VERSION>/latest/g" deploy/sidekiq.yml; \
	kubectl patch deployment/$(WEB_DEPLOYMENT) \
		-p "{\"spec\":{\"template\":{\"metadata\":{\"labels\":{\"date\":\"`date +'%s'`\"}}}}}"; \
	kubectl patch deployment/$(WORKER_DEPLOYMENT) \
		-p "{\"spec\":{\"template\":{\"metadata\":{\"labels\":{\"date\":\"`date +'%s'`\"}}}}}"; \
	kubectl patch deployment/$(PROXY_DEPLOYMENT) \
		-p "{\"spec\":{\"template\":{\"metadata\":{\"labels\":{\"date\":\"`date +'%s'`\"}}}}}" \
  git checkout deploy/

.PHONY: rollout-worker
rollout-worker:
	kubectl patch deployment/$(WORKER_DEPLOYMENT) \
		-p "{\"spec\":{\"template\":{\"metadata\":{\"annotations\":{\"date\":\"`date +'%s'`\"}}}}}"

.PHONY: rollout-proxy
rollout-proxy:
	kubectl patch deployment/$(PROXY_DEPLOYMENT) \
		-p "{\"spec\":{\"template\":{\"metadata\":{\"annotations\":{\"date\":\"`date +'%s'`\"}}}}}"

.PHONY: rollback
rollback:
	kubectl rollout undo deployment/$(WEB_DEPLOYMENT) && \
	kubectl rollout undo deployment/$(WORKER_DEPLOYMENT) && \

.PHONY: exec
exec:
	kubectl exec -it $$(kubectl get pods | grep $(WEB) | awk '/$(WEB)/ { print $$1 }') -c $(PROJECT) $(call args, );

.PHONY: exec-nginx
exec-nginx:
	kubectl exec -it $$(kubectl get pods | grep $(WEB) | awk '/$(WEB)/ { print $$1 }') -c $(NGINX) $(call args, );

.PHONY: exec-worker
exec-worker:
	kubectl exec -it $$(kubectl get pods | grep $(WORKER`) | awk '/$(WORKER)/ { print $$1 }') -c $(PROJECT) $(call args, );

.PHONY: exec-proxy
exec-proxy:
	kubectl exec -it $$(kubectl get pods | grep $(PROXY) | awk '/$(PROXY)/ { print $$1 }') -c $(PROXY) $(call args, );

.PHONY: logs
logs:
	kubectl logs $$(kubectl get pods | grep $(WEB) | awk '/$(WEB)/ { print $$1 }') $(PROJECT) -f;

.PHONY: logs-nginx
logs-nginx:
	kubectl logs $$(kubectl get pods | grep $(WEB) | awk '/$(WEB)/ { print $$1 }') $(NGINX) -f;

.PHONY: logs-worker
logs-worker:
	kubectl logs $$(kubectl get pods | grep $(WORKER) | awk '/$(WORKER)/ { print $$1 }') -f;

.PHONY: logs-proxy
logs-proxy:
	kubectl logs $$(kubectl get pods | grep $(PROXY) | awk '/$(PROXY)/ { print $$1 }') -f;

.PHONY: status
status:
	kubectl get all -o wide;

.PHONY: watch
watch:
	kubectl get pods -w -o wide;

.PHONY: db-migrate
db-migrate:
	-kubectl delete jobs/db-migrate && sed -i '' "s/<VERSION>/latest/g" deploy/jobs/db-migrate.yml && kubectl apply -f deploy/jobs/db-migrate.yml && git checkout deploy/

.PHONY: clean
clean:
	kubectl -n default delete pods --field-selector=status.phase=Failed
	-kubectl delete jobs/db-migrate;
