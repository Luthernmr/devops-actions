# Environment-Based Deployment Strategy

Ce document explique comment les workflows de test sont configurés pour déployer automatiquement dans l'environnement approprié en fonction de la branche Git.

## Stratégie de Branchement et Environnements

### Mapping Branche → Environnement

| Branche | Environnement | Description | Configuration |
|---------|---------------|-------------|---------------|
| `main` / `master` | **Production** | Déploiement en production avec configuration optimisée | Haute disponibilité, rollback automatique |
| `staging` | **Staging** | Environnement de pré-production pour tests d'intégration | Configuration similaire à la production |
| `develop` / `dev` | **Development** | Environnement de développement pour tests rapides | Configuration basique, déploiement rapide |
| Autres branches | **Development** | Branches de feature utilisent l'environnement de dev | Préfixe "feature" dans les noms |

### Configuration Automatique

Les workflows détectent automatiquement la branche et appliquent la configuration appropriée :

#### 🏷️ Tags d'Images
- **Production** (`main`): `latest`
- **Staging** (`staging`): `staging-{commit-sha}`
- **Development** (`develop`): `dev-{commit-sha}`
- **Feature branches**: `feature-{commit-sha}`

#### ⚙️ Configuration des Ressources

##### ECS
```yaml
# Development
cluster_suffix: dev
deployment_timeout: 15 minutes
auto_rollback: false
termination_wait_time: 3 minutes

# Staging  
cluster_suffix: staging
deployment_timeout: 20 minutes
auto_rollback: true
termination_wait_time: 5 minutes

# Production
cluster_suffix: prod
deployment_timeout: 45 minutes
auto_rollback: true
termination_wait_time: 10 minutes
deployment_strategy: Linear (10% every minute)
```

##### Lambda
```yaml
# Development
memory_size: 256 MB
timeout: 30 seconds
env_variables: {"ENV":"development","DEBUG":"true"}

# Staging
memory_size: 512 MB  
timeout: 45 seconds
env_variables: {"ENV":"staging","DEBUG":"true"}

# Production
memory_size: 1024 MB
timeout: 60 seconds
env_variables: {"ENV":"production","DEBUG":"false"}
```

## Déclencheurs des Workflows

### Automatiques
```yaml
on:
  push:
    branches: [main, develop, staging, prod]
  pull_request:
    branches: [main, develop]
```

### Manuels
```yaml
on:
  workflow_dispatch:  # Bouton "Run workflow" dans GitHub
```

## Secrets par Environnement

Chaque environnement utilise des secrets spécifiques pour l'isolation :

```yaml
# Development
secrets:
  ECS_DEV_OIDC_ROLE_ARN: ${{ secrets.ECS_DEV_OIDC_ROLE_ARN }}
  LAMBDA_DEV_OIDC_ROLE_ARN: ${{ secrets.LAMBDA_DEV_OIDC_ROLE_ARN }}

# Staging  
secrets:
  ECS_STAGING_OIDC_ROLE_ARN: ${{ secrets.ECS_STAGING_OIDC_ROLE_ARN }}
  LAMBDA_STAGING_OIDC_ROLE_ARN: ${{ secrets.LAMBDA_STAGING_OIDC_ROLE_ARN }}

# Production
secrets:
  ECS_PROD_OIDC_ROLE_ARN: ${{ secrets.ECS_PROD_OIDC_ROLE_ARN }}
  LAMBDA_PROD_OIDC_ROLE_ARN: ${{ secrets.LAMBDA_PROD_OIDC_ROLE_ARN }}
```

## Exemples d'Usage

### Déploiement de Development
```bash
# Push sur branche develop
git checkout develop
git push origin develop
# → Déploie automatiquement en development
```

### Déploiement de Staging
```bash
# Push sur branche staging
git checkout staging
git merge develop
git push origin staging
# → Déploie automatiquement en staging
```

### Déploiement de Production
```bash
# Push sur branche main
git checkout main
git merge staging
git push origin main
# → Déploie automatiquement en production
```

### Déploiement Manuel
1. Aller dans GitHub Actions
2. Sélectionner le workflow
3. Cliquer "Run workflow"
4. Choisir la branche
5. L'environnement sera automatiquement détecté

## Nommage des Ressources

Les ressources sont automatiquement nommées avec le suffixe d'environnement :

```yaml
# Development
cluster_name: my-app-dev-cluster
service_name: my-app-dev-service
function_name: my-lambda-function-dev

# Staging
cluster_name: my-app-staging-cluster
service_name: my-app-staging-service
function_name: my-lambda-function-staging

# Production
cluster_name: my-app-prod-cluster
service_name: my-app-prod-service
function_name: my-lambda-function-prod
```

## Surveillance et Rapports

Chaque déploiement génère un rapport automatique avec :

- ✅ Statut du déploiement par environnement
- 📋 Configuration appliquée (mémoire, timeout, etc.)
- 🏷️ Tag d'image utilisé
- 🎯 Environnement cible
- ⏱️ Durée du déploiement

## Bonnes Pratiques

### 🔄 Workflow de Développement
1. **Feature branches** → Development automatique
2. **Merge vers develop** → Tests d'intégration
3. **Promote vers staging** → Tests de pré-production
4. **Merge vers main** → Déploiement production

### 🛡️ Sécurité
- Chaque environnement a ses propres rôles IAM
- Secrets isolés par environnement
- Validation automatique avant déploiement production

### 🚀 Performance
- Development : Déploiement rapide, ressources minimales
- Staging : Configuration proche de la production
- Production : Haute disponibilité, rollback automatique

### 📊 Monitoring
- Logs séparés par environnement
- Métriques spécifiques à chaque env
- Alertes configurées selon la criticité

## Dépannage

### Problème : Mauvais environnement détecté
**Solution** : Vérifier le nom de la branche et la logique dans le job `configure`

### Problème : Secrets manquants
**Solution** : Vérifier que tous les secrets sont configurés pour l'environnement cible

### Problème : Déploiement échoue
**Solution** : Consulter les logs du job spécifique à l'environnement dans GitHub Actions
