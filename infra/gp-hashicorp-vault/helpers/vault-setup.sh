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

usage() {
  echo "Usage: $PRG [-h|s] cluster_name client_secret [access_token]"
}

help() {
  echo "Sets up the base HashiCorp Vault installation"
  echo
  usage
  echo "options:"
  echo "-h                 displays help"
  echo "-s                 skip non-repeatable actions. Requires access_token parameter to be set. Warning: this will override changes in some policies and configs! "
  echo
  echo "parameters:"
  echo "cluster_name      cluster's name, used in oidc redirect url setup"
  echo "client_secret     client secret for oidc setup"
  echo "access_token      OPTIONAL: a sufficiently privileged Vault token to perform the setup with (skips initialization). Required with -s"
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

if [ "${skip_non_repeatable}" = true ]; then
  shift
fi


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
if [[ -z "${ACCESS_TOKEN}" ]] && [[ "${skip_non_repeatable}" = true ]]; then
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

# DEFAULT SECRET STORE FOR CICD
if [ "${skip_non_repeatable}" = false ]; then
  kubectl exec vault-0 -n "${namespace}" -- sh -c "vault login -no-print ${ACCESS_TOKEN}  && vault secrets enable -path=development/cicd kv-v2"
fi

# DEFAULT POLICIES
# CICD-READER
kubectl exec vault-0 -n "${namespace}" -- sh -c "vault login -no-print ${ACCESS_TOKEN}  && \
    vault policy write cicd-reader \
      <(echo 'path \"/development/cicd/*\"
        {
          capabilities = [\"read\", \"list\"]
        }'
      )"

# CICD-ADMIN
kubectl exec vault-0 -n "${namespace}" -- sh -c "vault login -no-print ${ACCESS_TOKEN}  && \
    vault policy write cicd-admin \
      <(echo 'path \"/development/cicd/*\"
        {
          capabilities = [\"read\", \"list\", \"create\", \"update\", \"delete\"]
        }'
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
        }'
      )"

# ENABLE & CONFIGURE KUBERNETES AUTH INTEGRATION
if [ "${skip_non_repeatable}" = false ]; then
  kubectl exec vault-0 -n "${namespace}" -- sh -c "vault login -no-print ${ACCESS_TOKEN} && vault auth enable kubernetes"
fi

kubectl exec vault-0 -n "${namespace}" -- sh -c "vault login -no-print ${ACCESS_TOKEN} && vault write auth/kubernetes/config kubernetes_host=https://\${KUBERNETES_SERVICE_HOST}:\${KUBERNETES_SERVICE_PORT}"
kubectl exec vault-0 -n "${namespace}" -- sh -c "vault login -no-print ${ACCESS_TOKEN} && \
    vault write auth/kubernetes/role/cicd-reader \
      bound_service_account_names=operate-workflow-sa \
      bound_service_account_namespaces='*' \
      policies=cicd-reader \
      ttl=24h"

# ENABLE & CONFIGURE OIDC AUTH INTEGRATION
if [ "${skip_non_repeatable}" = false ]; then
  kubectl exec vault-0 -n "${namespace}" -- sh -c "vault login -no-print ${ACCESS_TOKEN} && vault auth enable oidc"
fi

# DEFAULT ROLE
kubectl exec vault-0 -n "${namespace}" -- sh -c "vault login -no-print ${ACCESS_TOKEN} && \
    vault write auth/oidc/role/default \
       bound_audiences='vault' \
       allowed_redirect_uris='https://vault-ui-gp-vault.apps.${CLUSTER}.gepaplexx.com/ui/vault/auth/oidc/oidc/callback' \
       allowed_redirect_uris='https://vault-ui-gp-vault.apps.${CLUSTER}.gepaplexx.com/oidc/callback' \
       user_claim='sub' \
       policies='default' \
       groups_claim='groups'"

kubectl exec vault-0 -n "${namespace}" -- sh -c "vault login -no-print ${ACCESS_TOKEN} && \
    vault write auth/oidc/config \
      oidc_client_id='vault' \
      oidc_discovery_url='https://sso.apps.${CLUSTER}.gepaplexx.com/realms/internal' \
      oidc_client_secret=${CLIENT_SECRET} \
      default_role=default"

# GROUP MAPPING
# Standard output gets piped to /dev/null for more uniform responses

OIDC_AUTH_ACCESSOR=$(kubectl exec vault-0 -n "${namespace}" -- sh -c "vault login -no-print ${ACCESS_TOKEN} && \
      vault auth list -format=json" | jq -r '."oidc/".accessor')

kubectl exec vault-0 -n "${namespace}" -- sh -c "vault login -no-print ${ACCESS_TOKEN} && \
    vault write identity/group \
      name='Gepaplexx' \
      type='external' \
      policies='admin,cicd-admin' \
      metadata=responsibility='Vault Admin'" 1> /dev/null
echo "Success! Data written to: identity/group/name/Gepaplexx"

if [ "${skip_non_repeatable}" = false ]; then
  GROUP_ID=$(kubectl exec vault-0 -n "${namespace}" -- sh -c "vault login -no-print ${ACCESS_TOKEN} && \
        vault read -field=id identity/group/name/Gepaplexx")
  kubectl exec vault-0 -n "${namespace}" -- sh -c "vault login -no-print ${ACCESS_TOKEN} && \
        vault write identity/group-alias name='Gepaplexx' \
           mount_accessor=${OIDC_AUTH_ACCESSOR} \
           canonical_id=${GROUP_ID}" 1> /dev/null
  echo "Success! Data written to: identity/group-alias/"
fi

kubectl exec vault-0 -n "${namespace}" -- sh -c "vault login -no-print ${ACCESS_TOKEN} && \
    vault write identity/group \
      name='Gepardec' \
      type='external' \
      policies='cicd-admin' \
      metadata=responsibility='Vault CICD Admin'" 1> /dev/null
echo "Success! Data written to: identity/group/name/Gepardec"

if [ "${skip_non_repeatable}" = false ]; then
  GROUP_ID=$(kubectl exec vault-0 -n "${namespace}" -- sh -c "vault login -no-print ${ACCESS_TOKEN} && \
        vault read -field=id identity/group/name/Gepardec")
  kubectl exec vault-0 -n "${namespace}" -- sh -c "vault login -no-print ${ACCESS_TOKEN} && \
        vault write identity/group-alias name='Gepardec' \
           mount_accessor=${OIDC_AUTH_ACCESSOR} \
           canonical_id=${GROUP_ID}" 1> /dev/null
  echo "Success! Data written to: identity/group-alias/"
fi

echo "==============================================="
echo "donesies. better have that cigarette finished."
echo "don't forget to save the vault-init.json file somewhere save. it contains the root token and the recovery keys"