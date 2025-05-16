#!/bin/bash

# === CONFIGURATION ===
POLICY_NAME="myservice"
POLICY_DIR="../policies"
MODULE_DIR="../modules"
LOG_FILE="../logs/build_policy.log"
TE_FILE="${POLICY_DIR}/${POLICY_NAME}.te"
FC_FILE="${POLICY_DIR}/${POLICY_NAME}.fc"
MOD_FILE="${MODULE_DIR}/${POLICY_NAME}.mod"
PP_FILE="${MODULE_DIR}/${POLICY_NAME}.pp"

# === HELPER FUNCTIONS ===
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') $1" | tee -a "$LOG_FILE"
}

fail_exit() {
    log "ERROR: $1"
    exit 1
}

# === SCRIPT START ===

# Ensure log directory exists
mkdir -p "$(dirname "$LOG_FILE")"

log "=== Building SELinux policy module: $POLICY_NAME ==="

# Check if required files exist
[[ -f "$TE_FILE" ]] || fail_exit "Missing .te file: $TE_FILE"
[[ -f "$FC_FILE" ]] || fail_exit "Missing .fc file: $FC_FILE"

# Create module directory if it doesn't exist
mkdir -p "$MODULE_DIR"

# Clean old files
rm -f "$MOD_FILE" "$PP_FILE"

# Step 1: Compile .te to .mod
log "Compiling $TE_FILE to $MOD_FILE..."
checkmodule -M -m -o "$MOD_FILE" "$TE_FILE" || fail_exit "Failed to compile .te to .mod"

# Step 2: Package .mod to .pp
log "Packaging $MOD_FILE to $PP_FILE with $FC_FILE..."
semodule_package -o "$PP_FILE" -m "$MOD_FILE" -f "$FC_FILE" || fail_exit "Failed to package .mod to .pp"

# Step 3: Install the .pp module
log "Installing SELinux module $PP_FILE..."
sudo semodule -i "$PP_FILE" || fail_exit "Failed to install policy module"

log "✅ SELinux module '$POLICY_NAME' installed successfully."

