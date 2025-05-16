# SELinux Policy Project

This repository contains a custom SELinux policy module for securing your service. Below is the project structure and examples of each file type.

---

## Project Structure

```
SELinux-policies/
├── policies/
│   ├── myservice.te              # Type Enforcement file
│   ├── myservice.fc              # File Contexts file
│   └── myservice.if              # Interface file
├── scripts/
│   └── build_policy.sh           # Build/install script
├── logs/
│   ├── build.log                 # Build log
|   └── selinux-denials.log       # denials log
└── README.md
```

---

## File Examples

### 1. Type Enforcement (`.te`)
```te
// filepath: policies/myservice.te

module myservice 1.0;

require {
    type httpd_t;
    type var_log_t;
    class file { read write open };
}

# Allow httpd to write to /var/log/mylog.log
allow httpd_t var_log_t:file { read write open };

```

---

### 2. File Contexts (`.fc`)
```fc
// filepath: policies/myservice.fc

/var/log/mylog\.log    system_u:object_r:var_log_t:s0

```

---

### 3. Interface (`.if`)
```m4
// filepath: policies/myservice.if

# Define the interface to allow external modules to interact with 'myservice' module
policy_module(myservice, 1.0)

# Declare allowed operations for other modules to interact with 'myservice' policy
interface(`myservice_read_file') {
    allow $1 var_log_t:file { read };
}

```

---

### 4. Build Script (`.sh`)
```sh
// filepath: scripts/build_policy.sh

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

```

---

### 5. Build Log (`.log`)
```log

// filepath: logs/build.log

2025-05-16 17:38:04 === Building SELinux policy module: myservice ===
2025-05-16 17:38:04 Compiling ../policies/myservice.te to ../modules/myservice.mod...
2025-05-16 17:38:04 Packaging ../modules/myservice.mod to ../modules/myservice.pp with ../policies/myservice.fc...
2025-05-16 17:38:04 Installing SELinux module ../modules/myservice.pp...
2025-05-16 17:38:17 ✅ SELinux module 'myservice' installed successfully.

```

---

## Usage

1. Edit the policy files in the `policies/` directory as needed.
2. Run the build script:
   ```sh
   cd scripts
   ./build_policy.sh
   ```
3. Check `logs/build.log` for build output.

---

## References

- [SELinux Project Documentation](https://selinuxproject.org/page/Main_Page)
- [Red Hat SELinux Guide](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/8/html/using_selinux/index)

---

## License

MIT License

