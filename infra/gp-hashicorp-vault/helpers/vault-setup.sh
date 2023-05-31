#!/bin/sh

#This script sets up HashiCorp Vault.
#For this it:
#  * enables kubernetes auth mode for serviceaccount authentication
#  * enables oidc auth mode and configures it with our keycloak
#  * sets up a few default roles, groups, and group mappings
#  * it also enables a secret store for cicd workflows
#
#TODO:
#  * CLEANUP
#  * Define Default Roles and Capabilities. Currently it's just a start and PoC

PRG=$(basename $0)
DIR=$(dirname $0)

namespace="gp-vault"
skip_non_repeatable=false

set -e

usage() {
  echo "Usage: $PRG [-h|s] cluster_name client_secret [access_token]"
}

help() {
  echo "Sets up the base HashiCorp Vault installation"
  echo
  usage
  echo """
  options:
  -h                 displays help
  -s                 skip non-repeatable actions. Requires access_token parameter to be set. Warning: this will override changes in some policies and configs!

  parameters:
  cluster_name      cluster's name, used in oidc redirect url setup
  client_secret     client secret for oidc setup
  access_token      OPTIONAL: a sufficiently privileged Vault token to perform the setup with (skips initialization). Required with -s"""
}

while getopts ":hs" option; do
   case $option in
      h)
        help
        exit;;
      s)
        skip_non_repeatable=true
        ;;
      \?)
        usage
        exit;;
   esac
done

shift $(( OPTIND - 1 ))

CLUSTER="${1}"
CLIENT_SECRET="${2}"
ACCESS_TOKEN="${3}"

if [ -z "${CLIENT_SECRET}" ]; then
  usage
  exit 1
fi
if [ -z "${CLUSTER}" ]; then
  usage
  exit 1
fi
if [ -z "${ACCESS_TOKEN}" ] && [ "${skip_non_repeatable}" = true ]; then
  echo "Skipping non repeatable actions requires an access token!"
  echo
  usage
  exit 1
fi

set -e

echo "Starting Vault setup..."
echo "==============================================="


# INITIALIZE VAULT
if [ -z "${ACCESS_TOKEN}" ]; then
  echo "initializing vault & waiting 10 seconds for initialization to be complete. don't worry. be happy. chill out. and grab a cigarette"
  kubectl exec vault-0 -n "${namespace}" -- sh -c "vault operator init -recovery-shares=3 -recovery-threshold=3 -format=json"  > "${DIR}"/vault-init-"${CLUSTER}".json
  sleep 10  # Required to ensure vault is correctly initialized and unsealed from GCP.
  ACCESS_TOKEN=$(cat "${DIR}"/vault-init-"${CLUSTER}".json | jq -r .root_token)
fi

# DEFAULT SECRET STORES
if [ "${skip_non_repeatable}" = false ]; then
  # Enable Audit Logging
  kubectl exec vault-0 -n "${namespace}" -- sh -c "vault login -no-print ${ACCESS_TOKEN} && vault audit enable file file_path=stdout"
  
  kubectl exec vault-0 -n "${namespace}" -- sh -c "vault login -no-print ${ACCESS_TOKEN} && vault secrets enable -path=development/cicd kv-v2"
  kubectl exec vault-0 -n "${namespace}" -- sh -c "vault login -no-print ${ACCESS_TOKEN} && vault secrets enable -path=development/admin kv-v2"
  # Prefill development/admin with required secrets for workflows.
  ARGOCD_URL=$(kubectl -n gepardec-run-cicd-tools get cm argocd-cm -o jsonpath='{.data.url}' | awk '{ print substr( $0, 9 )}')
  ARGOCD_PASSWORD=$(kubectl -n gepardec-run-cicd-tools get secret gepardec-run-cicd-tools-argocd-cluster -o jsonpath='{.data.admin\.password}' | base64 -d )
  kubectl exec vault-0 -n "${namespace}" -- sh -c "vault login -no-print ${ACCESS_TOKEN} && vault kv put development/admin/argo-access ARGOCD_URL=${ARGOCD_URL} ARGOCD_PASSWORD=${ARGOCD_PASSWORD}"

  # Configuration Secret Stores for Cluster Administration Secrets
  kubectl exec vault-0 -n "${namespace}" -- sh -c "vault login -no-print ${ACCESS_TOKEN} && vault secrets enable -path=cluster/config kv-v2"
fi

# ENABLE & CONFIGURE KUBERNETES AUTH INTEGRATION
if [ "${skip_non_repeatable}" = false ]; then
  kubectl exec vault-0 -n "${namespace}" -- sh -c "vault login -no-print ${ACCESS_TOKEN} && vault auth enable kubernetes"
fi
kubectl exec vault-0 -n "${namespace}" -- sh -c "vault login -no-print ${ACCESS_TOKEN} && vault write auth/kubernetes/config kubernetes_host=https://\${KUBERNETES_SERVICE_HOST}:\${KUBERNETES_SERVICE_PORT}"

KUBERNETES_AUTH_ACCESSOR=$(kubectl exec vault-0 -n "${namespace}" -- sh -c "vault login -no-print ${ACCESS_TOKEN} && \
      vault auth list -format=json" | jq -r '."kubernetes/".accessor')

# DEFAULT POLICIES
# CICD-READER
kubectl exec vault-0 -n "${namespace}" -- sh -c "vault login -no-print ${ACCESS_TOKEN} && \
    vault policy write cicd-reader \
      <(echo '
        path \"/development/cicd/data/{{identity.entity.aliases.${KUBERNETES_AUTH_ACCESSOR}.metadata.service_account_namespace}}/*\"
        {
          capabilities = [\"read\", \"list\"]
        }
        path \"development/admin/*\"
        {
          capabilities = [\"read\", \"list\"]
        }
        '
      )"

# CICD-ADMIN
kubectl exec vault-0 -n "${namespace}" -- sh -c "vault login -no-print ${ACCESS_TOKEN} && \
    vault policy write cicd-admin \
      <(echo '
        # This policy allows access to all cicd resources on development/*,
        # make sure it is only given to admins and SAs that are restricted to
        # GPX-only namespaces

        path \"development/cicd/*\"
        {
          capabilities = [\"read\", \"list\", \"create\", \"update\", \"delete\"]
        }
        path \"development/admin/*\"
        {
          capabilities = [\"read\", \"list\", \"create\", \"update\", \"delete\"]
        }
        '
      )"

# CLUSTER CONFIG ADMIN
kubectl exec vault-0 -n "${namespace}" -- sh -c "vault login -no-print ${ACCESS_TOKEN} && \
    vault policy write cluster-config-admin \
      <(echo '
        # This policy allows all access to cluster-configuration resources on cluster/config/*,
        # make sure it is only given to people responsible for configuring clusters, i.e. gepardec-run team members

        path \"cluster/config/*\"
        {
          capabilities = [\"read\", \"list\", \"create\", \"update\", \"delete\"]
        }
        '
      )"

# CLUSTER CONFIG READER
kubectl exec vault-0 -n "${namespace}" -- sh -c "vault login -no-print ${ACCESS_TOKEN} && \
    vault policy write cluster-config-reader \
      <(echo '
        # This policy allows read-only access to all cluster-configuration resources on cluster/config/*,
        # make sure it is only given to admins and SAs that are required to read initial secrets for configuration
        path \"cluster/config/*\"
        {
          capabilities = [\"read\", \"list\"]
        }
        '
      )"

# BACKUP-CREATOR
kubectl exec vault-0 -n "${namespace}" -- sh -c "vault login -no-print ${ACCESS_TOKEN} && \
    vault policy write backup-creator \
      <(echo '
        path \"/sys/storage/raft/snapshot\"
        {
          capabilities = [\"read\"]
        }
        '
      )"

# ADMIN
kubectl exec vault-0 -n "${namespace}" -- sh -c "vault login -no-print ${ACCESS_TOKEN} && \
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
        }

        path \"sys/storage/raft/*\"
        {
          capabilities = [\"read\", \"create\", \"update\", \"list\", \"delete\", \"sudo\"]
        }
        '
      )"

kubectl exec vault-0 -n "${namespace}" -- sh -c "vault login -no-print ${ACCESS_TOKEN} && \
    vault write auth/kubernetes/role/cicd-reader \
      bound_service_account_names=operate-workflow-sa \
      bound_service_account_namespaces='*' \
      policies=cicd-reader \
      ttl=24h"
kubectl exec vault-0 -n "${namespace}" -- sh -c "vault login -no-print ${ACCESS_TOKEN} && \
    vault write auth/kubernetes/role/backup-creator \
      bound_service_account_names=vault-backup-sa \
      bound_service_account_namespaces='gp-vault' \
      policies=backup-creator \
      ttl=1h"
kubectl exec vault-0 -n "${namespace}" -- sh -c "vault login -no-print ${ACCESS_TOKEN} && \
    vault write auth/kubernetes/role/cluster-config-reader \
      bound_service_account_names=admin-config-reader \
      bound_service_account_namespaces='*' \
      policies=cluster-config-reader \
      ttl=1h"

# ENABLE & CONFIGURE OIDC AUTH INTEGRATION
if [ "${skip_non_repeatable}" = false ]; then
  kubectl exec vault-0 -n "${namespace}" -- sh -c "vault login -no-print ${ACCESS_TOKEN} && vault auth enable oidc"
fi

# DEFAULT ROLE
kubectl exec vault-0 -n "${namespace}" -- sh -c "vault login -no-print ${ACCESS_TOKEN} && \
    vault write auth/oidc/role/default \
       bound_audiences='vault' \
       allowed_redirect_uris='https://vault.${CLUSTER}.play.gepardec.com/ui/vault/auth/oidc/oidc/callback' \
       allowed_redirect_uris='https://vault.${CLUSTER}.play.gepardec.com/oidc/callback' \
       user_claim='sub' \
       policies='default' \
       groups_claim='groups'"

kubectl exec vault-0 -n "${namespace}" -- sh -c "vault login -no-print ${ACCESS_TOKEN} && \
    vault write auth/oidc/config \
      oidc_client_id='vault' \
      oidc_discovery_url='https://sso.${CLUSTER}.play.run.gepardec.com/realms/internal' \
      oidc_client_secret=${CLIENT_SECRET} \
      default_role=default" || true # continue script even if keycloak is not accessible yet. configuration should get written correctly nonetheless

# GROUP MAPPING
# Standard output gets piped to /dev/null for more uniform responses

OIDC_AUTH_ACCESSOR=$(kubectl exec vault-0 -n "${namespace}" -- sh -c "vault login -no-print ${ACCESS_TOKEN} && \
      vault auth list -format=json" | jq -r '."oidc/".accessor')

kubectl exec vault-0 -n "${namespace}" -- sh -c "vault login -no-print ${ACCESS_TOKEN} && \
    vault write identity/group \
      name='gepardec-run-admins' \
      type='external' \
      policies='admin,cicd-admin,cluster-config-admin' \
      metadata=responsibility='Vault Admin'" 1> /dev/null
echo "Success! Data written to: identity/group/name/gepardec-run-admins"

if [ "${skip_non_repeatable}" = false ]; then
  GROUP_ID=$(kubectl exec vault-0 -n "${namespace}" -- sh -c "vault login -no-print ${ACCESS_TOKEN} && \
        vault read -field=id identity/group/name/gepardec-run-admins")
  kubectl exec vault-0 -n "${namespace}" -- sh -c "vault login -no-print ${ACCESS_TOKEN} && \
        vault write identity/group-alias name='gepardec-run-admins' \
           mount_accessor=${OIDC_AUTH_ACCESSOR} \
           canonical_id=${GROUP_ID}" 1> /dev/null
  echo "Success! Data written to: identity/group-alias/"
fi


echo "==============================================="
echo "donesies. better have that cigarette finished."
echo "don't forget to save the vault-init.json file somewhere save. it contains the root token and the recovery keys"
