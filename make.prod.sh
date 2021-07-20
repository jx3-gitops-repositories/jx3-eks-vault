#!/usr/bin/env bash

if gsed --version ; then
  echo "====== gsed ======"
  alias sedTool=gsed
else
    echo "====== sed ======"
  alias sedTool=sed
fi

# File removals
rm -rf helmfiles/tekton-pipelines
rm -rf helmfiles/nfs
# Modifications
sedTool -i 's/-jx././g' jx-requirements.yml
sedTool -i '/tekton-pipelines/d' helmfile.yaml
sedTool -i '/nfs/d' helmfile.yaml

# JX Chart removals
sedTool -i '/- chart: jxgh\/jx-pipelines-visualizer/,/  - jx-values.yaml/d' helmfiles/jx/helmfile.yaml
sedTool -i '/- chart: jxgh\/jx-preview/,/  - jx-values.yaml/d' helmfiles/jx/helmfile.yaml
sedTool -i '/- chart: jxgh\/lighthouse/,/  - jx-values.yaml/d' helmfiles/jx/helmfile.yaml
sedTool -i '/- chart: jxgh\/bucketrepo/,/  - jx-values.yaml/d' helmfiles/jx/helmfile.yaml
sedTool -i '/- chart: jxgh\/jx-build-controller/,/  - jx-values.yaml/d' helmfiles/jx/helmfile.yaml
sedTool -i '/- chart: jxgh\/nexus/,/  - jx-values.yaml/d' helmfiles/jx/helmfile.yaml
sedTool -i '/- chart: jxgh\/nexus/,/  - jx-values.yaml/d' helmfiles/jx/helmfile.yaml
sedTool -i '/- chart: vitech-sdlc\/tektonpipelines/,/  - jx-values.yaml/d' helmfiles/jx/helmfile.yaml
sedTool -i '/- chart: vitech-sdlc\/secret/,/  - jx-values.yaml/d' helmfiles/jx/helmfile.yaml
sedTool -i '/- chart: stable\/chartmuseum/,/  - jx-values.yaml/d' helmfiles/jx/helmfile.yaml
sedTool -i '/- chart: k8s-at-home\/oauth2-proxy/,/  - jx-values.yaml/d' helmfiles/jx/helmfile.yaml
sedTool -i '/- chart: jxgh\/cd-indicators/,/  - jx-values.yaml/d' helmfiles/jx/helmfile.yaml

# JX Chart additions (jx3/local-external-secrets chart)
sedTool -i '/templates:/ i \ \ \- chart: jx3/local-external-secrets' helmfiles/jx/helmfile.yaml
sedTool -i '/templates:/ i \ \ \  version: 0.0.14' helmfiles/jx/helmfile.yaml
sedTool -i '/templates:/ i \ \ \  name: local-external-secrets' helmfiles/jx/helmfile.yaml
sedTool -i '/templates:/ i \ \ \  values:' helmfiles/jx/helmfile.yaml
sedTool -i '/templates:/ i \ \ \  - jx-values.yaml' helmfiles/jx/helmfile.yaml

# jx-global-values changes
sedTool -i '/imagePullSecrets:/d' jx-global-values.yaml
sedTool -i '/jx:/ a\ \ \ - tekton-container-registry-auth' jx-global-values.yaml
sedTool -i '/jx:/ a\ \ imagePullSecrets:' jx-global-values.yaml

# Makefile changes
sedTool -i '/include/ i # lets disable the dev cluster settings' Makefile
sedTool -i '/include/ i COPY_SOURCE = no-copy-source' Makefile
sedTool -i '/include/ i GENERATE_SCHEDULER = no-gitops-scheduler' Makefile
sedTool -i '/include/ i REPOSITORY_RESOLVE = no-repository-resolve' Makefile
sedTool -i '/include/ i GITOPS_WEBHOOK_UPDATE = no-gitops-webhook-update' Makefile

jx gitops helmfile resolve

#git commit -a -m "chore: prod cluster repo init"
#git push

### Remote Prod Chart List
for i in $(find helmfiles -name helmfile.yaml); do
  echo
  echo $i
  grep -- ^-\ chart $i
done
