#!/usr/bin/env bash

# File              : eks_ebs_encryption_setup.sh
# Author            : Asaduzzaman 'Asad' Pavel <contact@iampavel.dev>
# Date              : 24.08.2025
# Description       : Enables default EBS encryption and encrypts existing unencrypted EBS volumes for EKS clusters

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log() { echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"; }
success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; }
warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }

# Check prerequisites (AWS CLI, jq, kubectl)
check_prerequisites() {
    if ! command -v aws &> /dev/null; then
        error "AWS CLI is not installed. Please install it first."
        exit 1
    fi
    if ! aws sts get-caller-identity &> /dev/null; then
        error "AWS CLI is not configured. Please run 'aws configure' first."
        exit 1
    fi
    if ! command -v jq &> /dev/null; then
        error "jq is not installed. Please install it first."
        exit 1
    fi
    if ! command -v kubectl &> /dev/null; then
        error "kubectl is not installed. Please install it first."
        exit 1
    fi

    # Check kubectl access to the cluster
    log "Verifying kubectl access to the EKS cluster..."
    if ! kubectl get nodes >/dev/null 2>&1; then
        error "Current IAM principal lacks access to Kubernetes objects. To fix:"
        error "1. Add the IAM principal to the aws-auth ConfigMap in the kube-system namespace."
        error "   Example: Add 'userarn: arn:aws:iam::$(aws sts get-caller-identity --query Account --output text):user/<your-user>' to mapUsers."
        error "2. Ensure the user has appropriate RBAC permissions (e.g., ClusterRole with access to persistentvolumes)."
        error "3. Verify kubeconfig with: aws eks update-kubeconfig --name <CLUSTER_NAME> --region <REGION>"
        exit 1
    fi
    success "Prerequisites and kubectl access verified"
}

# Enable default EBS encryption in a region
enable_default_encryption() {
    local region=$1
    log "Enabling default EBS encryption in region $region..."

    local enabled=$(aws ec2 get-ebs-encryption-by-default --region "$region" --query 'EbsEncryptionByDefault' --output text)
    if [ "$enabled" == "true" ]; then
        success "Default EBS encryption already enabled in $region"
        return
    fi

    aws ec2 enable-ebs-encryption-by-default --region "$region" >/dev/null 2>&1
    if [ $? -eq 0 ]; then
        success "Enabled default EBS encryption in $region"
    else
        error "Failed to enable default EBS encryption in $region"
    fi
}

# Encrypt an unencrypted EBS volume
encrypt_volume() {
    local region=$1
    local volume_id=$2
    local kms_key_id=$3

    log "Processing volume $volume_id in region $region"

    # Check if volume exists and is unencrypted
    local encrypted=$(aws ec2 describe-volumes --region "$region" --volume-ids "$volume_id" --query 'Volumes[0].Encrypted' --output text 2>/dev/null)
    if [ $? -ne 0 ]; then
        warning "Volume $volume_id does not exist or is inaccessible"
        return 1
    fi
    if [ "$encrypted" == "True" ]; then
        success "Volume $volume_id is already encrypted"
        return
    fi

    # Get volume details
    local volume_info=$(aws ec2 describe-volumes --region "$region" --volume-ids "$volume_id" --query 'Volumes[0]' --output json)
    local availability_zone=$(echo "$volume_info" | jq -r '.AvailabilityZone')
    local size=$(echo "$volume_info" | jq -r '.Size')
    local attachments=$(echo "$volume_info" | jq -r '.Attachments[] | "\(.InstanceId),\(.Device)"')

    # Create snapshot
    log "Creating snapshot for volume $volume_id..."
    local snapshot_id=$(aws ec2 create-snapshot --region "$region" --volume-id "$volume_id" --description "Snapshot for encryption of $volume_id" --query 'SnapshotId' --output text)
    if [ $? -ne 0 ]; then
        error "Failed to create snapshot for volume $volume_id"
        return 1
    fi
    aws ec2 wait snapshot-completed --region "$region" --snapshot-ids "$snapshot_id"
    success "Snapshot $snapshot_id created"

    # Create encrypted snapshot
    log "Creating encrypted snapshot from $snapshot_id..."
    local encrypted_snapshot_id=$(aws ec2 copy-snapshot --region "$region" --source-region "$region" --source-snapshot-id "$snapshot_id" --description "Encrypted copy of $snapshot_id" --encrypted --kms-key-id "$kms_key_id" --query 'SnapshotId' --output text)
    if [ $? -ne 0 ]; then
        error "Failed to create encrypted snapshot for $snapshot_id"
        aws ec2 delete-snapshot --region "$region" --snapshot-id "$snapshot_id"
        return 1
    fi
    aws ec2 wait snapshot-completed --region "$region" --snapshot-ids "$encrypted_snapshot_id"
    success "Encrypted snapshot $encrypted_snapshot_id created"

    # Create new encrypted volume
    log "Creating encrypted volume from snapshot $encrypted_snapshot_id..."
    local new_volume_id=$(aws ec2 create-volume --region "$region" --availability-zone "$availability_zone" --snapshot-id "$encrypted_snapshot_id" --volume-type gp3 --query 'VolumeId' --output text)
    if [ $? -ne 0 ]; then
        error "Failed to create encrypted volume from snapshot $encrypted_snapshot_id"
        aws ec2 delete-snapshot --region "$region" --snapshot-id "$encrypted_snapshot_id"
        aws ec2 delete-snapshot --region "$region" --snapshot-id "$snapshot_id"
        return 1
    fi
    aws ec2 wait volume-available --region "$region" --volume-ids "$new_volume_id"
    success "Created encrypted volume $new_volume_id"

    # Handle attachments
    if [ -n "$attachments" ]; then
        while IFS=',' read -r instance_id device; do
            log "Detaching original volume $volume_id from instance $instance_id..."
            aws ec2 detach-volume --region "$region" --volume-id "$volume_id" >/dev/null 2>&1
            aws ec2 wait volume-available --region "$region" --volume-ids "$volume_id"

            log "Attaching new volume $new_volume_id to instance $instance_id at $device..."
            aws ec2 attach-volume --region "$region" --volume-id "$new_volume_id" --instance-id "$instance_id" --device "$device" >/dev/null 2>&1
            aws ec2 wait volume-in-use --region "$region" --volume-ids "$new_volume_id"
            success "Attached encrypted volume $new_volume_id to instance $instance_id"
        done <<< "$attachments"
    fi

    # Cleanup
    log "Cleaning up original volume $volume_id and snapshots..."
    aws ec2 delete-volume --region "$region" --volume-id "$volume_id" >/dev/null 2>&1
    aws ec2 delete-snapshot --region "$region" --snapshot-id "$snapshot_id" >/dev/null 2>&1
    aws ec2 delete-snapshot --region "$region" --snapshot-id "$encrypted_snapshot_id" >/dev/null 2>&1
    success "Cleaned up resources for volume $volume_id"
}

# Update EKS node group launch template to enforce encryption
update_nodegroup_launch_template() {
    local cluster_name=$1
    local nodegroup_name=$2
    local region=$3
    local kms_key_id=$4

    log "Updating node group $nodegroup_name in cluster $cluster_name to enforce EBS encryption..."

    local launch_template_info=$(aws eks describe-nodegroup --cluster-name "$cluster_name" --nodegroup-name "$nodegroup_name" --region "$region" --query 'Nodegroup.LaunchTemplate' --output json)
    local launch_template_id=$(echo "$launch_template_info" | jq -r '.Id // ""')
    local launch_template_version=$(echo "$launch_template_info" | jq -r '.Version // ""')

    if [ -z "$launch_template_id" ]; then
        warning "No launch template found for node group $nodegroup_name. Ensure volumes are encrypted manually or via Auto Scaling group."
        return
    fi

    local template_data=$(aws ec2 describe-launch-template-versions --region "$region" --launch-template-id "$launch_template_id" --versions "$launch_template_version" --query 'LaunchTemplateVersions[0].LaunchTemplateData' --output json)
    local encryption_set=$(echo "$template_data" | jq -r '.BlockDeviceMappings[].Ebs.Encrypted // false')
    if [ "$encryption_set" == "true" ]; then
        success "Launch template $launch_template_id already enforces EBS encryption"
        return
    fi

    local updated_template_data=$(echo "$template_data" | jq --arg kms_key_id "$kms_key_id" '
        .BlockDeviceMappings |= map(.Ebs.Encrypted = true | if $kms_key_id != "" then .Ebs.KmsKeyId = $kms_key_id else . end)
    ')

    log "Creating new launch template version for $launch_template_id..."
    local new_version=$(aws ec2 create-launch-template-version --region "$region" --launch-template-id "$launch_template_id" --launch-template-data "$updated_template_data" --query 'LaunchTemplateVersion.VersionNumber' --output text)
    if [ $? -ne 0 ]; then
        error "Failed to create new launch template version for $launch_template_id"
        return 1
    fi
    success "Created new launch template version $new_version"

    log "Updating node group $nodegroup_name to use new launch template version..."
    aws eks update-nodegroup-config --cluster-name "$cluster_name" --nodegroup-name "$nodegroup_name" --region "$region" --launch-template "{ \"id\": \"$launch_template_id\", \"version\": \"$new_version\" }" >/dev/null 2>&1
    if [ $? -eq 0 ]; then
        success "Updated node group $nodegroup_name to use encrypted launch template"
    else
        error "Failed to update node group $nodegroup_name"
    fi
}

# Main execution
main() {
    log "Starting systematic EBS encryption for EKS clusters..."

    check_prerequisites

    # Configuration
    KMS_KEY_ID="arn:aws:kms:us-west-2:665804139994:key/eks-ebs"  # Optional: Specify custom KMS key (e.g., "arn:aws:kms:us-west-2:123456789012:key/...") or leave empty for default
    CLUSTER_NAME=""  # Replace with your EKS cluster name
    REGIONS="us-west-2"  # Specify regions to process (e.g., "us-west-2 us-east-1")

    # Enable default encryption and process volumes in each region
    for region in $REGIONS; do
        enable_default_encryption "$region"

        # Get EKS node groups
        nodegroups=$(aws eks list-nodegroups --cluster-name "$CLUSTER_NAME" --region "$region" --query 'Nodegroups' --output text)
        if [ -z "$nodegroups" ]; then
            warning "No node groups found for cluster $CLUSTER_NAME in region $region"
            continue
        fi

        # Update node groups to enforce encryption
        for nodegroup in $nodegroups; do
            update_nodegroup_launch_template "$CLUSTER_NAME" "$nodegroup" "$region" "$KMS_KEY_ID"
        done

        # Get instances in the EKS cluster
        instance_ids=$(aws ec2 describe-instances --region "$region" --filters "Name=tag:kubernetes.io/cluster/$CLUSTER_NAME,Values=owned" --query 'Reservations[].Instances[].InstanceId' --output text)
        if [ -z "$instance_ids" ]; then
            warning "No instances found for cluster $CLUSTER_NAME in region $region"
            continue
        fi

        # Process volumes for each instance
        for instance_id in $instance_ids; do
            volumes=$(aws ec2 describe-volumes --region "$region" --filters "Name=attachment.instance-id,Values=$instance_id" --query 'Volumes[].VolumeId' --output text)
            for volume_id in $volumes; do
                encrypt_volume "$region" "$volume_id" "$KMS_KEY_ID"
            done
        done

        # Process EBS-backed PersistentVolumes
        log "Checking for EBS-backed PersistentVolumes in cluster $CLUSTER_NAME..."
        if ! kubectl config use-context "arn:aws:eks:$region:$(aws sts get-caller-identity --query Account --output text):cluster/$CLUSTER_NAME" >/dev/null 2>&1; then
            error "Failed to set kubectl context for cluster $CLUSTER_NAME in region $region"
            continue
        fi
        pvs=$(kubectl get pv -o json 2>/dev/null | jq -r '.items[] | select(.spec.csi.driver=="ebs.csi.aws.com") | .spec.csi.volumeHandle' 2>/dev/null)
        if [ $? -ne 0 ]; then
            warning "Failed to list PersistentVolumes. Ensure IAM principal has RBAC permissions for 'persistentvolumes'."
            continue
        fi
        for pv_volume_id in $pvs; do
            warning "Processing PV volume $pv_volume_id. Ensure workloads are paused before replacing the volume."
            encrypt_volume "$region" "$pv_volume_id" "$KMS_KEY_ID"
            warning "PV volume $pv_volume_id replaced. Update PVCs to reference the new volume ID if necessary."
        done

        echo "----------------------------------------"
    done

    success "EBS encryption setup for EKS cluster $CLUSTER_NAME completed!"
    log "Note: Verify node group updates, volume attachments, and PV/PVC configurations. Node group updates may require instance replacement."
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
