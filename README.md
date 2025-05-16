# SELinux Policy Project

This repository contains a custom SELinux policy module for securing your service. Below is the project structure and examples of each file type.

---

## Project Structure

```
SELinux-policies/
├── policies/
│   ├── myservice.te      # Type Enforcement file
│   ├── myservice.fc      # File Contexts file
│   └── myservice.if      # Interface file
├── scripts/
│   └── build_policy.sh   # Build/install script
├── logs/
│   └── build.log         # Build log
└── README.md
```

---

## File Examples

### 1. Type Enforcement (`.te`)
```te
// filepath: policies/myservice.te
policy_module(myservice, 1.0)

type myservice_t;
type myservice_exec_t;
init_daemon_domain(myservice_t, myservice_exec_t)

allow myservice_t self:process { fork transition };
allow myservice_t var_log_t:file { read write open };
```

---

### 2. File Contexts (`.fc`)
```fc
// filepath: policies/myservice.fc
/opt/myservice/bin/myservice    --gen_context(system_u:object_r:myservice_exec_t,s0)
/var/log/myservice.log          --gen_context(system_u:object_r:var_log_t,s0)
```

---

### 3. Interface (`.if`)
```m4
// filepath: policies/myservice.if
interface(`myservice_log_access',`
    gen_require(`
        type myservice_t;
        type var_log_t;
    ')
    allow $1 var_log_t:file { read write open };
')
```

---

### 4. Build Script (`.sh`)
```sh
// filepath: scripts/build_policy.sh
#!/bin/bash
set -e

checkmodule -M -m -o ../modules/myservice.mod ../policies/myservice.te
semodule_package -o ../modules/myservice.pp -m ../modules/myservice.mod -f ../policies/myservice.fc
semodule -i ../modules/myservice.pp

echo "Policy built and installed successfully." | tee ../logs/build.log
```

---

### 5. Build Log (`.log`)
```log
// filepath: logs/build.log
Policy built and installed successfully.
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

