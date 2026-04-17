# Wazuh Linux SOC Dashboards for OpenSearch Dashboards

Pack de 3 dashboards OpenSearch Dashboards prêts à importer pour un SOC Linux sous Wazuh :

- Linux Security Overview
- SSH/Auth Attacks
- File Integrity Monitoring

## Prérequis

- OpenSearch Dashboards accessible en HTTPS
- Compte disposant des droits d'écriture sur le tenant cible
- Indices Wazuh présents :
  - `wazuh-alerts-*` requis
  - `wazuh-archives-*` optionnel pour les requêtes de test "raw"
- Champ temporel attendu : `timestamp` 
- Import via Saved Objects API avec header `osd-xsrf` 

## Structure

- `dashboards/` : fichiers NDJSON autoportants
- `scripts/` : import unitaire et import en lot
- `tests/` : requêtes et événements de validation
- `.github/workflows/` : pipeline GitHub Actions d'auto-déploiement

## Utilisation rapide

```bash
export OSD_URL="https://dashboards.example.org"
export OSD_USER="admin"
export OSD_PASS="change-me"
export SECURITY_TENANT="global"
export OVERWRITE="true"

./scripts/import-all.sh
```

## Import unitaire

```bash
./scripts/import-saved-object.sh dashboards/linux-security-overview.ndjson
./scripts/import-saved-object.sh dashboards/ssh-auth-attacks.ndjson
./scripts/import-saved-object.sh dashboards/file-integrity-monitoring.ndjson
```

## Adaptation si vos indices diffèrent

Le pack vise `wazuh-alerts-*`, qui couvre aussi les indices nommés en pratique `wazuh-alerts-4.x-*`.
Si vous utilisez un autre pattern, modifiez la valeur `attributes.title` de l'objet `index-pattern` 
dans chaque fichier NDJSON, ou créez un alias OpenSearch compatible.

## Dépannage

### Erreur 400 `Request must contain a osd-xsrf header` 
Ajoutez le header :
`-H 'osd-xsrf: true'` 

### Import dans le mauvais tenant
Définissez :
`-H "securitytenant: global"` 
ou le tenant voulu dans `SECURITY_TENANT`.

### Dashboards vides
Vérifiez :
- la présence de données dans `wazuh-alerts-*` 
- le champ temporel `timestamp` 
- la période sélectionnée (`Last 24 hours` ou `Last 7 days`)
- l'existence des champs utilisés par les visualisations

### Panels FIM who-data vides
Les panels `syscheck.audit.*` restent importables mais ne se rempliront que si le who-data est activé
sur les agents concernés.

### Panel "raw archives" absent
Normal : ce pack ne dépend pas de `wazuh-archives-*` pour préserver la portabilité.
