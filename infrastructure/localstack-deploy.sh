#!/bin/bash
set -e # Stops the script if any command fails

aws --endpoint-url=http://localhost:4566 cloudformation delete-stack \
    --stack-name patient-management

aws --endpoint-url=http://localhost:4566 cloudformation wait stack-delete-complete \
    --stack-name patient-management

aws --endpoint-url=http://localhost:4566 cloudformation deploy \
    --stack-name patient-management \
    --template-file "./cdk.out/localstack.template.json"

echo "=== Assigning network aliases on pm-net for ECS service discovery ==="
for c in $(docker ps --format "{{.Names}}" | grep "^floci-ecs"); do
  case "$c" in
    *auth-service*) alias_name="auth-service" ;;
    *patient-service*) alias_name="patient-service" ;;
    *billing-service*) alias_name="billing-service" ;;
    *analytics-service*) alias_name="analytics-service" ;;
    *APIGateway*|*api-gateway*) alias_name="api-gateway" ;;
    *) alias_name="" ;;
  esac
  if [ -n "$alias_name" ]; then
    echo "Attaching alias $alias_name -> $c"
    docker network disconnect pm-net "$c" 2>/dev/null || true
    docker network connect --alias "$alias_name" pm-net "$c"
  fi
done

ALB_DNS=$(aws --endpoint-url=http://localhost:4566 elbv2 describe-load-balancers \
    --query "LoadBalancers[0].DNSName" --output text)

echo "============================================="
echo "Deployment Complete! ALB DNS: http://$ALB_DNS"
echo "Health check: http://$ALB_DNS/health"
echo "============================================="