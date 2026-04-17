#!/usr/bin/env bash
set -euo pipefail

# Modification FIM attendue : rule.id 550
echo "# dashboard-test $(date -Is)" | sudo tee -a /etc/ssh/sshd_config >/dev/null

# Création FIM attendue : rule.id 554
sudo touch /tmp/wazuh-fim-added.txt

# Suppression FIM attendue : rule.id 553
sudo rm -f /tmp/wazuh-fim-added.txt

# Si who-data est activé, ces opérations alimentent aussi syscheck.audit.*
echo "192.168.32.5" | sudo tee -a /etc/hosts.allow >/dev/null
