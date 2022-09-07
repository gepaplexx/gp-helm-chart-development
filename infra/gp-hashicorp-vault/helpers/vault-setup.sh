#!/bin/sh

#This script sets up HashiCorp Vault.
#For this it:
#  * enables kubernetes auth mode for serviceaccount authentication
#  * enabled oidc auth mode and configures it with our keycloak
#  * sets up a few default roles, groups, and group mappings
#  * it also enables a secret store for cicd workflows
#
#TODO:
#  * CLEANUP
#  * Define Default Roles and Capabilities. Currently it's just a start and PoC
#  * additional parameter to not execute commands that cannot be executed multiple times.
#      e.g. auth method enablement
#  * write usage message and print in case of failure


CLUSTER="${1}"
CLIENT_SECRET="${2}"

if [ -z "${CLIENT_SECRET}" ]; then
  echo "client secret not set. Exiting...."
  exit 1
fi
if [ -z "${CLUSTER}" ]; then
  echo "Cluster not set. Exiting...."
  exit 1
fi

PRG=`basename $0`
DIR=$(dirname $0)

set -e

namespace="gp-vault"

# INITIALIZE VAULT
echo "initializing vault & waiting 10 seconds for initialization to be complete. don't worry. be happy. chill out. and grab a cigarette"
kubectl exec vault-0 -n "${namespace}" -- sh -c "vault operator init -recovery-shares=3 -recovery-threshold=3 -format=json"  > "${DIR}"/vault-init.json
sleep 10  # Required to ensure vault is correctly initialized and unsealed from GCP.
ROOT_TOKEN=$(cat "${DIR}"/vault-init.json | jq -r .root_token)

# DEFAULT SECRET STORE FOR CICD
kubectl exec vault-0 -n "${namespace}" -- sh -c "vault login -no-print ${ROOT_TOKEN}  && vault secrets enable -path=development/cicd kv-v2"

# DEFAULT POLICIES
# CICD-READER
kubectl exec vault-0 -n "${namespace}" -- sh -c "vault login -no-print ${ROOT_TOKEN}  && \
    vault policy write cicd-reader \
      <(echo 'path \"/development/cicd/*\"
        {
          capabilities = [\"read\", \"list\"]
        }'
      )"

kubectl exec vault-0 -n "${namespace}" -- sh -c "vault login -no-print ${ROOT_TOKEN}  && \
    vault policy write cicd-admin \
      <(echo 'path \"/development/cicd/*\"
        {
          capabilities = [\"read\", \"list\", \"create\", \"update\", \"delete\"]
        }'
      )"

# ADMIN
kubectl exec vault-0 -n "${namespace}" -- sh -c "vault login -no-print ${ROOT_TOKEN} && \
    vault policy write admin \
      <(echo '
        # Read system health check
        path \"sys/health\"
        {
          capabilities = [\"read\", \"sudo\"]
        }
        # Create and manage ACL policies broadly across Vault
        # List existing policies
        path \"sys/policies/acl\"
        {
          capabilities = [\"list\"]
        }
        # Create and manage ACL policies
        path \"sys/policies/acl/*\"
        {
          capabilities = [\"create\", \"read\", \"update\", \"delete\", \"list\", \"sudo\"]
        }
        # Enable and manage authentication methods broadly across Vault
        # Manage auth methods broadly across Vault
        path \"auth/*\"
        {
          capabilities = [\"create\", \"read\", \"update\", \"delete\", \"list\", \"sudo\"]
        }
        # Create, update, and delete auth methods
        path \"sys/auth/*\"
        {
          capabilities = [\"create\", \"update\", \"delete\", \"sudo\"]
        }
        # List auth methods
        path \"sys/auth\"
        {
          capabilities = [\"read\"]
        }
        # Manage secrets engines
        path \"sys/mounts/*\"
        {
          capabilities = [\"create\", \"read\", \"update\", \"delete\", \"list\", \"sudo\"]
        }
        # List existing secrets engines.
        path \"sys/mounts\"
        {
          capabilities = [\"read\"]
        }
        # List and manage leases
        path \"sys/leases/lookup/*\"
        {
          capabilities = [\"list\", \"sudo\"]
        }
        path \"sys/leases/lookup\"
        {
          capabilities = [\"list\", \"sudo\"]
        }
        path \"sys/leases/revoke\"
        {
          capabilities = [\"update\", \"delete\"]
        }
        # watch logs
        path \"sys/monitor\"
        {
          capabilities = [\"read\"]
        }
        # identity
        path \"sys/identity/*\"
        {
          capabilities = [\"read\", \"create\", \"update\", \"list\"]
        }
        # identity
        path \"sys/identity/group\"
        {
          capabilities = [\"read\", \"create\", \"update\", \"list\"]
        }'
      )"

# ENABLE & CONFIGURE KUBERNETES AUTH INTEGRATION
kubectl exec vault-0 -n "${namespace}" -- sh -c "vault login -no-print ${ROOT_TOKEN} && vault auth enable kubernetes"
kubectl exec vault-0 -n "${namespace}" -- sh -c "vault login -no-print ${ROOT_TOKEN} && vault write auth/kubernetes/config kubernetes_host=https://\${KUBERNETES_SERVICE_HOST}:\${KUBERNETES_SERVICE_PORT}"
kubectl exec vault-0 -n "${namespace}" -- sh -c "vault login -no-print ${ROOT_TOKEN} && \
    vault write auth/kubernetes/role/cicd-reader \
      bound_service_account_names=operate-workflow-sa \
      bound_service_account_namespaces='*' \
      policies=cicd-reader \
      ttl=24h"

# ENABLE & CONFIGURE OIDC AUTH INTEGRATION
kubectl exec vault-0 -n "${namespace}" -- sh -c "vault login -no-print ${ROOT_TOKEN} && vault auth enable oidc"
# DEFAULT ROLE
kubectl exec vault-0 -n "${namespace}" -- sh -c "vault login -no-print ${ROOT_TOKEN} && \
    vault write auth/oidc/role/default \
       bound_audiences='vault' \
       allowed_redirect_uris='https://vault-ui-gp-vault.apps.${CLUSTER}.gepaplexx.com/ui/vault/auth/oidc/oidc/callback' \
       allowed_redirect_uris='https://vault-ui-gp-vault.apps.${CLUSTER}.gepaplexx.com/oidc/callback' \
       user_claim='sub' \
       policies='default' \
       groups_claim='groups'"

kubectl exec vault-0 -n "${namespace}" -- sh -c "vault login -no-print ${ROOT_TOKEN} && \
    vault write auth/oidc/config \
      oidc_client_id='vault' \
      oidc_discovery_url='https://sso.apps.${CLUSTER}.gepaplexx.com/realms/internal' \
      oidc_client_secret=${CLIENT_SECRET} \
      default_role=default"

# GROUP MAPPING

OIDC_AUTH_ACCESSOR=$(kubectl exec vault-0 -n "${namespace}" -- sh -c "vault login -no-print ${ROOT_TOKEN} && \
      vault auth list -format=json" | jq -r '."oidc/".accessor')

kubectl exec vault-0 -n "${namespace}" -- sh -c "vault login -no-print ${ROOT_TOKEN} && \
    vault write identity/group \
      name='Gepaplexx' \
      type='external' \
      policies='admin,cicd-admin' \
      metadata=responsibility='Vault Admin'"

GROUP_ID=$(kubectl exec vault-0 -n "${namespace}" -- sh -c "vault login -no-print ${ROOT_TOKEN} && \
      vault read -field=id identity/group/name/Gepaplexx")
kubectl exec vault-0 -n "${namespace}" -- sh -c "vault login -no-print ${ROOT_TOKEN} && \
      vault write identity/group-alias name='Gepaplexx' \
         mount_accessor=${OIDC_AUTH_ACCESSOR} \
         canonical_id=${GROUP_ID}"


kubectl exec vault-0 -n "${namespace}" -- sh -c "vault login -no-print ${ROOT_TOKEN} && \
    vault write identity/group \
      name='Gepardec' \
      type='external' \
      policies='cicd-admin' \
      metadata=responsibility='Vault CICD Admin'"

GROUP_ID=$(kubectl exec vault-0 -n "${namespace}" -- sh -c "vault login -no-print ${ROOT_TOKEN} && \
      vault read -field=id identity/group/name/Gepardec")
kubectl exec vault-0 -n "${namespace}" -- sh -c "vault login -no-print ${ROOT_TOKEN} && \
      vault write identity/group-alias name='Gepardec' \
         mount_accessor=${OIDC_AUTH_ACCESSOR} \
         canonical_id=${GROUP_ID}"
