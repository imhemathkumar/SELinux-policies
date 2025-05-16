# Implementing SELinux Policies for System Security Enforcement

## Objective
To enhance the security of a web server by writing a custom SELinux policy that allows only required access.

## Approach
- Collected AVC denials from `audit.log`.
- Wrote a `.te` file to define required permissions.
- Compiled and loaded the SELinux policy module.
- Verified restricted access was properly enforced.

## Commands Used
- ausearch
- checkmodule
- semodule_package
- semodule

## Outcome
- Service operates securely with SELinux enforcing correct policy.
