# Guide de déploiement sur Wazuh existant

## Prérequis Wazuh

- Wazuh Manager avec OpenSearch Dashboards installé
- Accès admin à OpenSearch Dashboards
- Indices Wazuh actifs : `wazuh-alerts-*`
- Port OpenSearch Dashboards (par défaut : 443 ou 5601)

## Méthode 1: Import manuel via script (recommandé)

### 1. Cloner le repo

```bash
cd /tmp
git clone https://github.com/VulneZe/DashboardWazuh.git
cd DashboardWazuh
```

### 2. Configurer les variables d'environnement

```bash
# URL de votre OpenSearch Dashboards Wazuh
export OSD_URL="https://votre-wazuh-dashboard.example.com"

# Identifiants admin Wazuh
export OSD_USER="admin"
export OSD_PASS="votre-mot-de-passe-admin"

# Tenant (généralement "global" pour Wazuh standard)
export SECURITY_TENANT="global"

# Écraser les dashboards existants
export OVERWRITE="true"
```

### 3. Rendre les scripts exécutables

```bash
chmod +x scripts/*.sh
```

### 4. Importer les dashboards

```bash
./scripts/import-all.sh
```

## Méthode 2: Import manuel via interface web

### 1. Accéder à OpenSearch Dashboards

Ouvrez votre navigateur sur : `https://votre-wazuh-dashboard.example.com`

### 2. Se connecter avec admin

Utilisez les identifiants admin de votre Wazuh.

### 3. Importer chaque fichier NDJSON

1. Cliquez sur **Menu** (☰) → **Management** → **Saved Objects**
2. Cliquez sur **Import** 
3. Sélectionnez le fichier : `dashboards/linux-security-overview.ndjson`
4. Cochez **Overwrite all** si demandé
5. Cliquez sur **Import**
6. Répétez pour :
   - `dashboards/ssh-auth-attacks.ndjson`
   - `dashboards/file-integrity-monitoring.ndjson`

## Méthode 3: Import via curl direct

```bash
curl -u "${OSD_USER}:${OSD_PASS}" \
  -H 'osd-xsrf: true' \
  -H "securitytenant: ${SECURITY_TENANT:-global}" \
  -X POST \
  "${OSD_URL%/}/api/saved_objects/_import?overwrite=true" \
  -F "file=@dashboards/linux-security-overview.ndjson;type=application/ndjson"

curl -u "${OSD_USER}:${OSD_PASS}" \
  -H 'osd-xsrf: true' \
  -H "securitytenant: ${SECURITY_TENANT:-global}" \
  -X POST \
  "${OSD_URL%/}/api/saved_objects/_import?overwrite=true" \
  -F "file=@dashboards/ssh-auth-attacks.ndjson;type=application/ndjson"

curl -u "${OSD_USER}:${OSD_PASS}" \
  -H 'osd-xsrf: true' \
  -H "securitytenant: ${SECURITY_TENANT:-global}" \
  -X POST \
  "${OSD_URL%/}/api/saved_objects/_import?overwrite=true" \
  -F "file=@dashboards/file-integrity-monitoring.ndjson;type=application/ndjson"
```

## Vérification du déploiement

### 1. Vérifier les dashboards importés

Dans OpenSearch Dashboards :
- Menu → Dashboards
- Vous devriez voir 3 dashboards :
  - **Linux Security Overview**
  - **SSH/Auth Attacks**
  - **File Integrity Monitoring**

### 2. Vérifier les données

Ouvrez chaque dashboard et vérifiez :
- Période : **Last 24 hours** (par défaut)
- Données présentes dans les panels
- Index pattern : `wazuh-alerts-*`

## Troubleshooting Wazuh

### Erreur "No data found"

**Cause** : Pas d'alertes dans `wazuh-alerts-*`

**Solution** :
```bash
# Vérifier les indices Wazuh
curl -u "${OSD_USER}:${OSD_PASS}" \
  "${OSD_URL%/}/_cat/indices/wazuh-alerts-*?v"

# Vérifier qu'il y a des alertes
curl -u "${OSD_USER}:${OSD_PASS}" \
  "${OSD_URL%/}/wazuh-alerts-*/_count"
```

### Erreur "Request must contain a osd-xsrf header"

**Cause** : Header manquant dans la requête

**Solution** : Les scripts incluent déjà ce header. Si vous utilisez curl manuel, ajoutez :
```bash
-H 'osd-xsrf: true'
```

### Dashboards vides après import

**Causes possibles** :
1. Pas d'alertes récentes (24h)
2. Champ temporel incorrect
3. Filtres trop restrictifs

**Solutions** :
1. Étendre la période à **Last 7 days**
2. Vérifier le champ `timestamp` existe
3. Tester les requêtes dans Discover avec les filtres du dashboard

### Erreur d'authentification

**Cause** : Identifiants incorrects ou permissions insuffisantes

**Solution** :
```bash
# Tester l'authentification
curl -u "${OSD_USER}:${OSD_PASS}" \
  "${OSD_URL%/}/api/security/authenticate"
```

## Adaptation pour votre environnement Wazuh

### Si vos indices ont un nom différent

Modifiez les fichiers NDJSON pour changer `wazuh-alerts-*` vers votre pattern :

```bash
# Exemple : si vos indices sont wazuh-alerts-4.x-*
sed -i 's/"title":"wazuh-alerts-\*"/"title":"wazuh-alerts-4.x-*"/g' dashboards/*.ndjson
```

### Si vous utilisez un port différent

Modifiez `OSD_URL` :
```bash
export OSD_URL="https://votre-wazuh-dashboard.example.com:5601"
```

### Si vous utilisez HTTP au lieu de HTTPS

```bash
export OSD_URL="http://votre-wazuh-dashboard.example.com"
export CURL_INSECURE="true"
```

## Test des dashboards

### Générer des alertes SSH de test

```bash
# Sur un agent Linux Wazuh
for i in $(seq 1 8); do
  logger -p authpriv.notice -t sshd "Failed password for invalid user test from 192.168.1.100 port 22 ssh2"
done
```

### Générer des alertes FIM de test

```bash
# Sur un agent Linux Wazuh avec syscheck activé
sudo touch /tmp/test-wazuh-fim.txt
echo "test" >> /tmp/test-wazuh-fim.txt
sudo rm /tmp/test-wazuh-fim.txt
```

## Maintenance

### Mettre à jour les dashboards

```bash
cd /tmp/DashboardWazuh
git pull
./scripts/import-all.sh
```

### Supprimer les dashboards

Dans OpenSearch Dashboards :
- Management → Saved Objects
- Sélectionner les dashboards
- Cliquez sur **Delete**
