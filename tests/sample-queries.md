# Requêtes de validation

## Linux overview
rule.groups:(sshd or syscheck or pam or audit or auditd or authentication_failed or authentication_success or authentication_failures or invalid_login)
(rule.groups:(sshd or syscheck or pam or audit or auditd or authentication_failed or authentication_success or authentication_failures or invalid_login) or location:syscheck or decoder.name:(sshd or sudo)) and rule.level >= 10

## SSH/Auth
rule.groups:(authentication_failed or authentication_failures or invalid_login)
rule.groups:authentication_success
(rule.groups:(sshd or authentication_failed or authentication_success or authentication_failures or invalid_login) or decoder.name:sshd) and srcip:*

## FIM
rule.groups:syscheck
rule.id:(550 or 553 or 554)
syscheck.path:"/etc/ssh/sshd_config"

## Archives si activés
index = wazuh-archives-* puis :
program_name:sshd
full_log:"Failed password"
