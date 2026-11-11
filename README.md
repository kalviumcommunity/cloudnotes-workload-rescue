# CloudNotes Workload Rescue

CloudNotes fails its local Kubernetes release checks. Investigate and repair three manifest faults, then prove authenticated notes survive application Pod replacement.

## Student workflow

Fork this repository, clone your personal fork, and create `fix/workload-rescue`. Use a free editor and the isolated environment created below. Work only in namespace `cloudnotes-rescue`.

**Never push fixes to `kalviumcommunity/cloudnotes-workload-rescue` or open a pull request against it.** Commit/push only to your personal fork after checking `git remote -v`. Submit one PDF through the assessment portal. No PR is required anywhere.

Repair only `k8s/deployment.yaml` and `k8s/service.yaml`. Three planted faults exist across these two files. Application, image, ConfigMap, Secret, PVC, client Pod, probes, resource settings, and helper scripts are supplied; do not modify or bypass them. Do not add optional references, literal credentials, extra volumes, or direct Pod requests as a replacement for required Service tests.

## Application contract

- Image: `cloudnotes-workload:1.0.0`, preloaded into cluster nodes. No image build/download is part of the timed work.
- Application listens on all interfaces at port 8080. Intended Service is `cloudnotes`, ClusterIP, port 80.
- Required environment: `APP_ENV`, `DATA_DIR`, `API_TOKEN`. Runtime configuration comes from supplied Kubernetes objects.
- Data written inside the directory configured by `DATA_DIR` must survive application Pod replacement using existing `cloudnotes-data` PVC. One replica and `Recreate` strategy are intentional for this small SQLite exercise.
- `GET /health`: HTTP 200 with status ok.
- `GET /info`: runtime mode and storage directory (no credential value).
- `POST /notes`: HTTP 201 with saved note; `GET /notes`: saved notes. Both require the injected practice token.
- Client Pod already has the intended authentication configuration. Request helper runs inside it, uses Service DNS, and never prints token values.

## Command reference

```bash
kubectl -n cloudnotes-rescue get pods,pvc,svc
kubectl -n cloudnotes-rescue describe pod <pod-name>
kubectl -n cloudnotes-rescue get events --sort-by=.lastTimestamp
kubectl -n cloudnotes-rescue logs deployment/cloudnotes
kubectl -n cloudnotes-rescue describe secret cloudnotes-access
kubectl -n cloudnotes-rescue get configmap cloudnotes-config -o yaml
kubectl -n cloudnotes-rescue apply -f k8s/deployment.yaml
kubectl -n cloudnotes-rescue apply -f k8s/service.yaml
kubectl -n cloudnotes-rescue rollout status deployment/cloudnotes --timeout=90s
kubectl -n cloudnotes-rescue get pods -l app=cloudnotes -o wide
kubectl -n cloudnotes-rescue get endpointslices -l kubernetes.io/service-name=cloudnotes -o yaml
bash scripts/request.sh GET /health
bash scripts/request.sh GET /info
bash scripts/request.sh POST /notes 'my-rescue-note'
bash scripts/request.sh GET /notes
kubectl -n cloudnotes-rescue get pods -l app=cloudnotes -o custom-columns=NAME:.metadata.name,UID:.metadata.uid,READY:.status.containerStatuses[0].ready
kubectl -n cloudnotes-rescue delete pod -l app=cloudnotes
kubectl -n cloudnotes-rescue rollout status deployment/cloudnotes --timeout=90s
```

Quote custom-column arguments containing brackets if your shell expands them. A startup configuration error may produce no application logs because the container never started; use events/describe rather than claiming nonexistent previous logs. Pod Running does not mean Ready, and an endpoint alone does not prove successful HTTP routing.

Do not expose Secret values: use `describe secret` for key names, not `get secret -o yaml`, decoded values, environment dumps, or authorization headers. Do not delete PVC, Secret, namespace, or unrelated workloads. Save only disposable practice notes.

## Self-service setup — before timer

Use Linux, macOS or WSL2, Bash, Git, Python 3, curl, and a running Docker Engine. Supported host/engine architectures: amd64 and arm64. Allow at least 2 CPUs, 4 GB free memory and 10 GB free disk for Docker. Initial downloads require internet access to GitHub, kind, Kubernetes and Docker image registries. Docker Desktop is optional where its free-use licence applies. No cloud, payment or registry login needed.

```bash
bash scripts/prepare-lab.sh
source .lab/env.sh
kubectl -n cloudnotes-rescue get pods,pvc,svc
```

Setup downloads checksum-verified local kind and Kubernetes 1.32.2 kubectl, creates dedicated `cloudnotes-ca4` kind cluster and private kubeconfig, builds and imports actual application/client image, verifies non-root writes on Bound PVC, generates disposable authentication Secret and applies broken baseline. It never edits repair files. Host kubectl version and other clusters are not used. Client must be Ready and PVC Bound; application startup failure remains intentional. Start timer only after `SETUP READY`. Source `.lab/env.sh` in every terminal. Do not run setup again during tasks: it reapplies baseline. Setup errors are not repair faults; resolve them before timing without deleting unrelated resources.

Capture original failures, minimal manifest changes, Ready rollout, Service-DNS responses and same note after Pod replacement in your PDF. Never capture token values.

After saving evidence, optional cleanup deletes **only this lab and its practice data**:

```bash
.lab/bin/kind delete cluster --name cloudnotes-ca4
rm -rf .lab
```

For a fresh attempt use a fresh clone after cleanup. Never delete unrelated clusters or use system prune.
