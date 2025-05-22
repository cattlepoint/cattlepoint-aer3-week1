#!/usr/bin/env bash
set -euo pipefail
regions=(us-east-1 us-east-2 eu-central-1 eu-west-1)

# Identity
aws sts get-caller-identity --query '[Account,Arn]' --output text 2>/dev/null \
  | { read acct arn || true; printf '# Account:%s  Arn:%s\n' "$acct" "$arn"; }

# Table header
printf '%s\n' 'Region      Type     ID/Arn                           Name'
printf '%s\n' '----------- -------- ------------------------------- -----------------------------'

for r in "${regions[@]}"; do
  region_has_resources=false
  row() { printf '%-11s %-8s %-31s %s\n' "$r" "$1" "$2" "${3:--}"; region_has_resources=true; }

  # EC2
  out=$(aws ec2 describe-instances --region "$r" \
        --filters Name=instance-state-name,Values=pending,running,stopping,stopped \
        --query 'Reservations[].Instances[].[InstanceId,Tags[?Key==`Name`]|[0].Value]' --output text)
  while IFS=$'\t' read -r id name; do [[ -n $id ]] && row EC2 "$id" "$name"; done <<< "$out"

  # EKS
  for c in $(aws eks list-clusters --region "$r" --query 'clusters' --output text); do
    cname=$(aws eks describe-cluster --region "$r" --name "$c" --query 'cluster.tags.Name' --output text 2>/dev/null)
    row EKS "$c" "$cname"
  done

  # RDS
  out=$(aws rds describe-db-instances --region "$r" \
        --query 'DBInstances[].[DBInstanceIdentifier,TagList[?Key==`Name`]|[0].Value]' --output text)
  while IFS=$'\t' read -r id name; do [[ -n $id ]] && row RDS "$id" "$name"; done <<< "$out"

  # Classic ELB
  for lb in $(aws elb describe-load-balancers --region "$r" \
               --query 'LoadBalancerDescriptions[].LoadBalancerName' --output text); do
    lbname=$(aws elb describe-tags --region "$r" --load-balancer-names "$lb" \
               --query 'TagDescriptions[0].Tags[?Key==`Name`].Value' --output text 2>/dev/null)
    row ELB "$lb" "$lbname"
  done

  # ALB / NLB
  out=$(aws elbv2 describe-load-balancers --region "$r" \
        --query 'LoadBalancers[].[LoadBalancerArn,Type]' --output text)
  while IFS=$'\t' read -r arn type; do
    [[ -z $arn ]] && continue
    lbname=$(aws elbv2 describe-tags --region "$r" --resource-arns "$arn" \
               --query 'TagDescriptions[0].Tags[?Key==`Name`].Value' --output text 2>/dev/null)
    row "$type" "$arn" "$lbname"
  done <<< "$out"

  # NAT Gateways
  out=$(aws ec2 describe-nat-gateways --region "$r" \
        --filter Name=state,Values=available,pending \
        --query 'NatGateways[].[NatGatewayId,Tags[?Key==`Name`]|[0].Value]' --output text)
  while IFS=$'\t' read -r id name; do [[ -n $id ]] && row NATGW "$id" "$name"; done <<< "$out"

  # Non-default VPCs
  out=$(aws ec2 describe-vpcs --region "$r" \
        --query 'Vpcs[?IsDefault==`false`].[VpcId,Tags[?Key==`Name`]|[0].Value]' --output text)
  while IFS=$'\t' read -r id name; do [[ -n $id ]] && row VPC "$id" "$name"; done <<< "$out"

  if $region_has_resources; then
    printf '%-11s %-8s\n' "$r" FOUND
  else
    printf '%-11s %-8s\n' "$r" OK
  fi
done
