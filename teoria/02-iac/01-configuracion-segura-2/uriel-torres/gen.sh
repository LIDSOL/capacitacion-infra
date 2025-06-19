#!/bin/bash

# Exit on error
set -e

# --- Configuration ---
IMAGE_URL="https://cloud.debian.org/images/cloud/bookworm/latest/debian-12-generic-amd64.qcow2"
BASE_IMAGE_FILENAME="debian-12-generic-amd64.qcow2"

# Standard directory for libvirt images. Ensure it exists and you have permissions.
IMAGE_DIR="/var/lib/libvirt/images"
VM_PREFIX="debian-vm-"
NUM_VMS=3
RAM_MB=1024 # RAM for each VM in MB
VCPUS=1     # Number of vCPUs for each VM
DISK_SIZE="15G" # Disk size for each VM
LIBVIRT_NETWORK="default" # Libvirt network to connect to

# --- SSH Configuration (Add your public key here) ---
SSH_PUBLIC_KEY="$(cat ~/.ssh/vm_key.pub)"

# --- Helper Functions ---
check_command() {
    command -v "$1" >/dev/null 2>&1 || { echo >&2 "Error: '$1' is not installed. Please install it and try again."; exit 1; }
}

# --- Initialization Function ---
initialize_environment() {
    echo "--- Initializing Environment ---"
    check_command "wget"
    check_command "virt-install"
    check_command "qemu-img"
    check_command "virsh"

if ! sudo virsh net-info "$LIBVIRT_NETWORK" 2>/dev/null | grep -q "Active: *yes"; then
    echo "Libvirt network '$LIBVIRT_NETWORK' is not active or does not exist. Attempting to start/define it..."
    sudo virsh net-start "$LIBVIRT_NETWORK" || sudo virsh net-autostart "$LIBVIRT_NETWORK" || { echo >&2 "Failed to start network '$LIBVIRT_NETWORK'. Please check libvirt network configuration."; exit 1; }
    echo "Network '$LIBVIRT_NETWORK' started and set to autostart."
else
    echo "Libvirt network '$LIBVIRT_NETWORK' is already active."
fi
}

# --- VM Creation Function ---
create_vms() {
    if [ ! -f "$IMAGE_DIR/$BASE_IMAGE_FILENAME" ]; then
        echo "Error: Base image not found. Please run the script with 'init' action first."
        exit 1
    fi

    echo "--- Creating VMs ---"

    BASE_IMAGE_PATH="$IMAGE_DIR/$BASE_IMAGE_FILENAME"

    for i in $(seq 1 $NUM_VMS); do
        VM_NAME="${VM_PREFIX}${i}"
        VM_DISK_PATH="${IMAGE_DIR}/${VM_NAME}.qcow2"
        TEMP_CLOUD_INIT_DIR=""

        echo ""
        echo "-----------------------------------------------------"
        echo "Processing VM: $VM_NAME"
        echo "-----------------------------------------------------"

        if sudo virsh dominfo "$VM_NAME" >/dev/null 2>&1; then
            echo "VM '$VM_NAME' already exists. Skipping."
            continue
        fi

        echo "Creating disk for '$VM_NAME' at '$VM_DISK_PATH'..."
        sudo cp "$BASE_IMAGE_PATH" "$VM_DISK_PATH"
        sudo chmod 644 "$VM_DISK_PATH"

        echo "Resizing disk '$VM_DISK_PATH' to $DISK_SIZE..."
        sudo qemu-img resize "$VM_DISK_PATH" "$DISK_SIZE"

        TEMP_CLOUD_INIT_DIR=$(mktemp -d "/tmp/cloud-init-${VM_NAME}.XXXXXX")
        USER_DATA_FILE="${TEMP_CLOUD_INIT_DIR}/user-data"
        META_DATA_FILE="${TEMP_CLOUD_INIT_DIR}/meta-data"

        cat <<EOF > "$USER_DATA_FILE"
#cloud-config
hostname: $VM_NAME
manage_etc_hosts: true
ssh_authorized_keys:
  - ${SSH_PUBLIC_KEY}
EOF

        INSTANCE_ID="id-$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c10)-${VM_NAME}"
        cat <<EOF > "$META_DATA_FILE"
instance-id: $INSTANCE_ID
local-hostname: $VM_NAME
EOF

        echo "Cloud-init user-data for '$VM_NAME':"
        cat "$USER_DATA_FILE"
        echo "Cloud-init meta-data for '$VM_NAME':"
        cat "$META_DATA_FILE"

        echo "Installing '$VM_NAME'..."
        sudo virt-install \
            --name "$VM_NAME" \
            --memory "$RAM_MB" \
            --vcpus "$VCPUS" \
            --disk "path=$VM_DISK_PATH,format=qcow2,bus=virtio,cache=none" \
            --osinfo "debian12" \
            --network "network=$LIBVIRT_NETWORK,model=virtio" \
            --graphics "none" \
            --noautoconsole \
            --import \
            --cloud-init "user-data=${USER_DATA_FILE},meta-data=${META_DATA_FILE}"

        if [ -d "$TEMP_CLOUD_INIT_DIR" ]; then
            echo "Cleaning up temporary cloud-init directory: $TEMP_CLOUD_INIT_DIR"
            rm -rf "$TEMP_CLOUD_INIT_DIR"
        fi

        echo ""
        echo "VM '$VM_NAME' created successfully."
        echo "To connect to its console: sudo virsh console $VM_NAME. Default user is 'debian'."
        echo "Console access is the primary way in. The image may take a minute for initial boot and cloud-init setup."
    done

    echo ""
    echo "-----------------------------------------------------"
    echo "All requested VMs processed."
    echo "-----------------------------------------------------"
    echo "Summary:"
    echo "- Base image: $BASE_IMAGE_PATH"
    echo "- VMs created in '$IMAGE_DIR' with prefix '$VM_PREFIX'"
    echo "- Network: '$LIBVIRT_NETWORK'"
    echo "Remember to manage these VMs using 'virsh' command (e.g., 'sudo virsh list --all', 'sudo virsh start $VM_NAME', 'sudo virsh destroy $VM_NAME')."
}

# --- VM Deletion Function ---
delete_vms() {
    echo "--- Deleting VMs ---"
    check_command "virsh"

    for i in $(seq 1 $NUM_VMS); do
        VM_NAME="${VM_PREFIX}${i}"
        VM_DISK_PATH="${IMAGE_DIR}/${VM_NAME}.qcow2"

        echo ""
        echo "-----------------------------------------------------"
        echo "Attempting to delete VM: $VM_NAME"
        echo "-----------------------------------------------------"

        # Check if VM exists using dominfo
        if sudo virsh dominfo "$VM_NAME" >/dev/null 2>&1; then
            echo "VM '$VM_NAME' found."

            # Check state and stop (destroy) if running
            VM_STATE=$(sudo virsh domstate "$VM_NAME" 2>/dev/null || echo "unknown")
            if [ "$VM_STATE" == "running" ]; then
                echo "VM '$VM_NAME' is running. Attempting to stop (destroy) it..."
                sudo virsh destroy "$VM_NAME"
                sleep 2
            elif [ "$VM_STATE" == "shut off" ]; then
                echo "VM '$VM_NAME' is already shut off."
            elif [ "$VM_STATE" == "unknown" ]; then
                echo "Could not determine state for VM '$VM_NAME'. It might be already undefined or in an error state."
            else
                echo "VM '$VM_NAME' is in state '$VM_STATE'."
            fi

            echo "Undefining VM '$VM_NAME' and attempting to remove associated storage..."
            if sudo virsh undefine "$VM_NAME" --remove-all-storage; then
                echo "VM '$VM_NAME' undefined and its storage should have been removed by libvirt."
            else
                echo "Warning: 'virsh undefine --remove-all-storage' failed for '$VM_NAME'."
                echo "Attempting to undefine '$VM_NAME' without automatic storage removal..."
                if sudo virsh undefine "$VM_NAME"; then
                    echo "VM '$VM_NAME' undefined (without automatic storage removal)."
                    if [ -f "$VM_DISK_PATH" ]; then
                        echo "Attempting to manually delete disk '$VM_DISK_PATH'..."
                        if sudo rm -f "$VM_DISK_PATH"; then
                            echo "Disk '$VM_DISK_PATH' manually deleted."
                        else
                            echo "Error: Failed to manually delete disk '$VM_DISK_PATH'."
                        fi
                    else
                        echo "Disk '$VM_DISK_PATH' not found for manual deletion (possibly removed by a previous step or never existed)."
                    fi
                else
                    echo "Error: Failed to undefine VM '$VM_NAME'. Manual cleanup might be required for definition and disk."
                fi
            fi

            if [ -f "$VM_DISK_PATH" ]; then
                echo "Warning: Disk '$VM_DISK_PATH' for VM '$VM_NAME' might still exist. Please verify manually."
            else
                echo "Disk for '$VM_NAME' appears to be successfully removed or was not found after deletion process."
            fi
            echo "VM '$VM_NAME' deletion processing complete."
        else
            echo "VM '$VM_NAME' not found by 'virsh dominfo'. Skipping."
        fi
    done
    echo ""
    echo "-----------------------------------------------------"
    echo "VM deletion process finished."
    echo "-----------------------------------------------------"
}

# --- VM Info Function ---
info_vms() {
    echo "--- Retrieving VM Information ---"
    check_command "virsh"

    for i in $(seq 1 $NUM_VMS); do
        VM_NAME="${VM_PREFIX}${i}"
        echo ""
        echo "-----------------------------------------------------"
        echo "Information for VM: $VM_NAME"
        echo "-----------------------------------------------------"

        if ! sudo virsh dominfo "$VM_NAME" >/dev/null 2>&1; then
            echo "VM '$VM_NAME' does not exist or is not defined."
            continue
        fi

        IFACES_INFO=$(sudo virsh domifaddr "$VM_NAME" --source lease 2>/dev/null || echo "Could not retrieve IP addresses.")

        if [[ "$IFACES_INFO" == "Could not retrieve IP addresses." ]] || [[ -z "$IFACES_INFO" ]]; then
            echo "  No IP addresses found via DHCP lease. VM might be off, not have an IP, or guest agent might be needed for other methods."
        else
            echo "$IFACES_INFO"
        fi
    done
    echo ""
    echo "-----------------------------------------------------"
    echo "VM information retrieval process finished."
    echo "-----------------------------------------------------"
}


# --- Main Script Logic ---

# Argument parsing for actions
if [ -z "$1" ]; then
    echo "Error: No action specified."
    echo "Usage: $0 [init|create|delete|info]"
    exit 1
fi

ACTION="$1"

if [ "$ACTION" == "create" ]; then
    echo "Create action requested."
    initialize_environment
    create_vms
elif [ "$ACTION" == "delete" ]; then
    echo "Delete action requested."
    initialize_environment
    delete_vms
elif [ "$ACTION" == "init" ]; then
    echo "Initialization action requested."
    initialize_environment
elif [ "$ACTION" == "info" ]; then
    echo "Information action requested."
    initialize_environment
    info_vms
else
    echo "Invalid action: $ACTION"
    echo "Usage: $0 [init|create|delete|info]"
    exit 1
fi

exit 0
