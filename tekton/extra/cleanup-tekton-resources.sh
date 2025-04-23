#!/bin/bash

#############################################################
# Helper Functions
#############################################################

# Check if a PV exists in the cluster
# Args:
#   $1: Name of the PV to check
# Returns: 0 if exists, 1 if not
check_pv_exists() {
    local pv_name=$1
    kubectl get pv $pv_name &>/dev/null
    return $?
}

# Check if any kubernetes resource exists in the cluster
# Args:
#   $1: Resource type (e.g., pv, pvc, pipelinerun)
#   $2: Resource name
# Returns: 0 if exists, 1 if not
check_resource_exists() {
    local resource_type=$1
    local resource_name=$2
    kubectl get $resource_type $resource_name &>/dev/null
    return $?
}

# Run a command with a timeout
# This function handles both Linux (using timeout command) and macOS (using perl)
# Args:
#   $1: Timeout in seconds
#   $@: The command to run and its arguments
# Returns: 0 if command succeeds, 1 if timeout or failure
run_with_timeout() {
    local timeout=$1
    shift
    
    # First try GNU timeout (available on Linux)
    if command -v timeout >/dev/null 2>&1; then
        # Run the command with timeout and suppress output
        timeout "${timeout}s" "$@" >/dev/null 2>&1
        local exit_code=$?
        # Handle timeout command exit codes:
        # 124: timeout occurred
        # 0: successful completion
        # others: command failed
        if [ $exit_code -eq 124 ]; then
            return 1  # Timed out
        else
            return $exit_code
        fi
    else
        # Fall back to perl timeout implementation for macOS
        # This creates a timeout using perl's alarm function
        perl -e '
            eval {
                local $SIG{ALRM} = sub { die "timeout\n" };
                alarm $ARGV[0] + 0;  # Convert timeout to number
                exec @ARGV[1..$#ARGV];  # Execute the command
            };
            if ($@ eq "timeout\n") {
                exit 1;  # Exit with error if timeout occurred
            }
        ' "$timeout" "$@" >/dev/null 2>&1
    fi
}

#############################################################
# Main Resource Deletion Function
#############################################################

# Delete a kubernetes resource with timeout and force if needed
# Args:
#   $1: Resource type (e.g., pv, pvc, pipelinerun)
#   $2: Resource name
# Returns: 0 if deletion successful, 1 if failed
delete_with_timeout() {
    local resource_type=$1
    local resource_name=$2
    local timeout_seconds=10  # Adjust timeout as needed

    echo "Deleting $resource_type $resource_name..."
    echo "Waiting up to ${timeout_seconds} seconds for deletion..."
    echo

    # Start the deletion process in background
    # --wait=false allows us to monitor the deletion ourselves
    kubectl delete $resource_type $resource_name --wait=false >/dev/null 2>&1 &
    local start_time=$(date +%s)
    
    # Monitor the deletion process
    while check_resource_exists $resource_type $resource_name; do
        # Calculate how long we've been waiting
        local current_time=$(date +%s)
        local elapsed_time=$((current_time - start_time))
        
        # If we've waited longer than our timeout
        if [ $elapsed_time -ge $timeout_seconds ]; then
            echo "Regular delete timed out after ${timeout_seconds}s, attempting force delete..."
            echo
            
            # Force delete process:
            # 1. Remove finalizers to unblock deletion
            # 2. Force delete with no grace period
            echo "Force deleting $resource_type $resource_name..."
            kubectl patch $resource_type $resource_name -p '{"metadata":{"finalizers":[]}}' --type=merge >/dev/null 2>&1
            kubectl delete $resource_type $resource_name --force --grace-period=0 >/dev/null 2>&1
            
            # Verify the force deletion
            if ! check_resource_exists $resource_type $resource_name; then
                echo "$resource_type $resource_name was force deleted successfully"
                echo
            else
                echo "Warning: $resource_type $resource_name still exists after force delete attempt"
                echo
            fi
            return 1
        fi
        sleep 1  # Wait 1 second before checking again
    done
    
    # If we get here, the resource was deleted successfully
    echo "$resource_type $resource_name deleted successfully"
    echo
    return 0
}

#############################################################
# Main Script
#############################################################

# Get all PVCs that are owned by PipelineRuns
# Format: PVC_NAME    KIND    PIPELINERUN_NAME
# Store the output in a variable to check if any resources were found
resources=$(kubectl get pvc -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.metadata.ownerReferences[0].kind}{"\t"}{.metadata.ownerReferences[0].name}{"\n"}{end}' | grep PipelineRun || true)

if [ -z "$resources" ]; then
    echo "No Tekton resources found to clean up"
    exit 0
fi

echo "$resources" | while read line; do
    # Extract the resource names from each line
    pvc=$(echo $line | awk '{print $1}')
    pr=$(echo $line | awk '{print $3}')
    
    # Find the corresponding PV for this PVC
    pv=$(kubectl get pv | grep $pvc | awk '{print $1}')
    
    # Display the resources we're about to clean up
    echo "Found resources:"
    echo "PipelineRun: $pr"
    echo "PVC: $pvc"
    echo "PV: $pv"
    echo "-------------------"
    echo
    
    # Delete resources in order:
    # 1. PipelineRun (owner)
    # 2. PVC (owned resource)
    # 3. PV (if not automatically deleted)
    delete_with_timeout pipelinerun $pr
    delete_with_timeout pvc $pvc
    
    # Give the system some time to automatically delete the PV
    echo "Waiting 5 seconds for PV cleanup..."
    echo
    sleep 5
    
    # Check if we need to manually delete the PV
    if check_pv_exists $pv; then
        echo "PV $pv still exists, attempting deletion..."
        echo
        delete_with_timeout pv $pv
    else
        echo "PV $pv was automatically deleted"
        echo
    fi
    
    echo "Cleanup complete for this set of resources"
    echo "================================="
    echo
done
