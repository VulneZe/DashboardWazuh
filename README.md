# Wazuh SOC Dashboards - Architecture Professionnelle

Pack de dashboards OpenSearch Dashboards basés sur l'architecture SOC professionnelle Wazuh 4.14.

## Pack Professionnel SOC (8 Dashboards)

**Niveau 1 - Pack de Pilotage SOC** (tableaux d'ouverture quotidiens)
- **SOC 01 - Executive Overview** - Vue d'ensemble avec KPIs critiques, évolution, top agents, MITRE tactics, severity distribution, incident queue
- **SOC 02 - Threat Detection / Active Incidents** - Détection et corrélation : règles actives, IP agressives, comptes ciblés, MITRE heatmap, timeline incidents
- **SOC 06 - Agent Health & Telemetry Reliability** - État des agents et fiabilité télémétrie : Active/Disconnected/Pending, versions agents, agents silencieux

**Niveau 2 - Pack d'Investigation** (investigation ciblée)
- **SOC 03 - Authentication & Privilege Abuse** - Bruteforce, password spraying, comptes anormaux, élévation de privilèges
- **SOC 04 - Endpoint Integrity / FIM Critical Changes** - Changements sensibles, webroots, points de persistence
- **SOC 05 - Vulnerability Prioritization** - CVE prioritization, hosts exposés, packages critiques, remediation priority
- **SOC 07 - Windows Security Monitoring** - Logons, privilèges, process, services, RDP, PowerShell
- **SOC 08 - Linux Security Monitoring** - SSH, sudo, root, cron/systemd, téléchargements suspects

## Index Patterns Utilisés

Le bundle utilise 4 index patterns Wazuh :
- `wazuh-alerts-*` - Alertes corrélées
- `wazuh-monitoring-*` - Statut des agents
- `wazuh-states-vulnerabilities-*` - État des vulnérabilités
- `wazuh-statistics-*` - Métriques du serveur

## Charte Visuelle Professionnelle

Palette fixe par sévérité (cohérence sur tous les dashboards) :
- **Critical** (level >= 10) : `#B42318` (rouge sombre)
- **High** (level 7-9) : `#F79009` (orange)
- **Medium** (level 4-6) : `#FEC84B` (ambre)
- **Low** (level 0-3) : `#12B76A` (vert)
- **Info** : `#2E90FA` (bleu)
- **Unknown/No data** : `#667085` (gris)

## Structure Uniforme des Dashboards

Chaque dashboard suit la même structure ergonomique :
1. **Header** - Description et périmètre
2. **Rangée KPI** - 5 à 8 tuiles métriques clés
3. **Rangée évolution** - Area/bar charts pour tendances
4. **Rangée Top N** - Horizontal bars pour top agents, règles, etc.
5. **Rangée table de travail** - Data table pour analyste

## Où sont stockés les dashboards ?

Les dashboards sont stockés dans **OpenSearch Dashboards** (l'interface web de Wazuh) :

1. **Dans l'index OpenSearch** : Les dashboards sont sauvegardés dans l'index `.kibana` ou `.opensearch` de votre cluster OpenSearch
2. **Via l'interface web** : Accessible via **Management > Saved Objects** dans OpenSearch Dashboards
3. **Export/Import** : Vous pouvez exporter vos dashboards en NDJSON depuis l'interface web

**Pour voir vos dashboards importés :**
- Connectez-vous à OpenSearch Dashboards
- Allez dans **Dashboards** dans le menu de gauche
- Vos dashboards apparaissent dans la liste

## Carte géographique des connexions

**Pourquoi elle n'est pas incluse :**
- Wazuh n'inclut pas les données géographiques (GeoIP) par défaut
- Nécessite l'activation du module GeoIP dans la configuration Wazuh
- Requiert une base de données GeoIP (MaxMind)

**Pour l'activer :**
1. Télécharger la base GeoIP MaxMind
2. Configurer `/var/ossec/etc/ossec.conf` avec `<geoip>`
3. Redémarrer Wazuh
4. Les champs `GeoIP.location` et `GeoIP.country_code` seront disponibles dans les alertes

## Identifiants de connexion requis

Pour utiliser les scripts d'import, vous devez fournir les identifiants de connexion à votre instance OpenSearch Dashboards.

### Où trouver les identifiants ?

**Méthode 1 - Via l'interface Wazuh :**
1. Connectez-vous à l'interface web Wazuh (généralement `https://<wazuh-server>/`)
2. Les identifiants sont les mêmes que ceux utilisés pour vous connecter à Wazuh
3. L'utilisateur doit avoir les droits d'administration pour importer des dashboards

**Méthode 2 - Via OpenSearch Dashboards :**
1. Connectez-vous directement à OpenSearch Dashboards (généralement `https://<wazuh-server>/app/wazuh`)
2. Utilisez le même utilisateur/mot de passe que pour Wazuh

**Méthode 3 - Via le serveur Wazuh :**
```bash
# Sur le serveur Wazuh
cat /var/ossec/api/configuration/api.yaml
# Ou vérifiez les fichiers de configuration OpenSearch
cat /etc/opensearch/opensearch-security/internal_users.yml
```

**Variables d'environnement requises :**
```bash
export OSD_URL="https://172.20.10.4:443"  # URL de votre OpenSearch Dashboards
export OSD_USER="admin"                   # Utilisateur avec droits admin
export OSD_PASS="votre_mot_de_passe"      # Mot de passe
export SECURITY_TENANT=""                 # Vide si pas de multi-tenancy
export OVERWRITE="true"                   # Écraser les dashboards existants
export CURL_INSECURE="true"               # Si certificat SSL auto-signé
```

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

⚠️ **IMPORTANT : Vous devez définir les variables d'environnement AVANT de lancer le script**

```bash
# Définir les variables d'environnement (obligatoire)
export OSD_URL="https://172.20.10.4:443"  # URL de votre OpenSearch Dashboards
export OSD_USER="admin"                   # Utilisateur avec droits admin
export OSD_PASS="votre_mot_de_passe"      # Mot de passe
export SECURITY_TENANT=""                 # Vide si pas de multi-tenancy
export OVERWRITE="true"                   # Écraser les dashboards existants
export CURL_INSECURE="true"               # Si certificat SSL auto-signé

# Lancer l'import
./scripts/import-all.sh
```

**Si vous obtenez l'erreur "OSD_URL is required"**, c'est que vous n'avez pas défini les variables d'environnement. Copiez et collez les commandes `export` ci-dessus avant de lancer le script.

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
