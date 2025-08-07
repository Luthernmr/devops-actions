# DevOps Actions

Collection d'actions GitHub réutilisables pour les déploiements DevOps sur AWS et Docker.

## 📊 Vue d'ensemble des Actions

| Catégorie | Action | Description | Dernière MAJ | Maintenue | Statut |
|-----------|--------|-------------|---------------|-----------|--------|
| **AWS ECS** | [deploy-ecs](aws/actions/deploy-ecs/action.yml) | Déploie une image Docker sur AWS ECS | 2025-08-07 | ⚠️ | Non testé |
| **AWS ECS** | [deploy-ecs-blue-green](aws/actions/deploy-ecs-blue-green/action.yml) | Déploie sur ECS avec stratégie blue-green via CodeDeploy | 2025-08-07 | ⚠️ | Non testé |
| **AWS ECS** | [rollback-ecs](aws/actions/rollback-ecs/action.yml) | Rollback d'un déploiement ECS vers une révision précédente | 2025-08-07 | ⚠️ | Non testé |
| **AWS ECS** | [setup-codedeploy-ecs](aws/actions/setup-codedeploy-ecs/action.yml) | Configure CodeDeploy pour les déploiements ECS blue-green | 2025-08-07 | ⚠️ | Non testé |
| **AWS Lambda** | [deploy-lambda](aws/actions/deploy-lambda/action.yml) | Déploie une fonction Lambda depuis un zip ou code source | 2025-08-07 | ✅ | Testé & Fonctionnel |
| **AWS Lambda** | [deploy-lambda-docker](aws/actions/deploy-lambda-docker/action.yml) | Déploie une fonction Lambda via image Docker | 2025-08-07 | ⚠️ | Non testé |
| **AWS Infra** | [infracost-estimate](aws/actions/infracost-estimate/action.yml) | Estimation des coûts d'infrastructure | 2025-08-07 | ❌ | En développement |
| **Docker** | [build-and-tag](docker/actions/build-and-tag/action.yml) | Build une image Docker avec plusieurs tags | 2025-08-07 | ⚠️ | Non testé |
| **Docker** | [login-dockerhub](docker/actions/login-dockerhub/action.yml) | Authentification DockerHub | 2025-08-07 | ⚠️ | Non testé |
| **Docker** | [login-ecr](docker/actions/login-ecr/action.yml) | Authentification AWS ECR via OIDC | 2025-08-07 | ⚠️ | Non testé |
| **Docker** | [login-acr](docker/actions/login-acr/action.yml) | Authentification Azure Container Registry | 2025-08-07 | ⚠️ | Non testé |

## 📋 Légende des Statuts

| Statut | Description |
|--------|-------------|
| ✅ Maintenue | Action activement maintenue et testée |
| ⚠️ Non testé | Action implémentée mais non testée en production |
| ❌ En développement | Action en cours de développement |
| 🔄 Migration | Action en cours de migration vers une nouvelle version |

## 🚀 Workflows Prêts à l'emploi

| Workflow | Description | Actions utilisées |
|----------|-------------|-------------------|
| [deploy-ecs.yml](aws/workflows/deploy-ecs.yml) | Déploiement ECS standard | deploy-ecs |
| [deploy-ecs-blue-green.yml](aws/workflows/deploy-ecs-blue-green.yml) | Déploiement ECS blue-green | deploy-ecs-blue-green, setup-codedeploy-ecs |
| [deploy-lambda.yml](aws/workflows/deploy-lambda.yml) | Déploiement Lambda | deploy-lambda |
| [deploy-lambda-docker.yml](aws/workflows/deploy-lambda-docker.yml) | Déploiement Lambda Docker | deploy-lambda-docker, login-ecr |
| [build-and-push.yml](docker/workflows/build-and-push.yml) | Build et push d'images Docker | build-and-tag, login-* |
| [rollback-ecs.yml](aws/workflows/rollback-ecs.yml) | Rollback ECS | rollback-ecs |
| [infracost-estimate.yml](aws/workflows/infracost-estimate.yml) | Estimation coûts | infracost-estimate |

## 📅 Calendrier de Maintenance

### Actions à Tester (Prochainement)
- [ ] **deploy-ecs** - Tests de déploiement ECS (priorité haute)
- [ ] **deploy-ecs-blue-green** - Tests blue-green avec CodeDeploy
- [ ] **rollback-ecs** - Tests de rollback automatique
- [ ] **deploy-lambda-docker** - Tests Lambda avec images Docker
- [ ] **login-ecr** - Tests d'authentification ECR
- [ ] **build-and-tag** - Tests de build Docker

### Actions à Compléter
- [ ] **infracost-estimate** - Compléter l'implémentation (échéance: fin août 2025)
- [ ] **setup-codedeploy-ecs** - Tests d'intégration CodeDeploy

### Actions Fonctionnelles ✅
- [x] **deploy-lambda** - Testé et validé en production (7 août 2025)

## 📊 Métriques de Qualité

| Métrique | Valeur |
|----------|--------|
| Actions totales | 11 |
| Actions testées et fonctionnelles | 1 |
| Actions non testées | 9 |
| Actions en développement | 1 |
| Couverture de tests | 9% |
| Documentation | 100% |

## 🔧 Structure du Projet

```
devops-actions/
├── aws/                    # Actions AWS
│   ├── actions/           # Actions réutilisables
│   └── workflows/         # Workflows d'exemple
├── docker/                # Actions Docker
│   ├── actions/           # Actions réutilisables
│   └── workflows/         # Workflows d'exemple
└── README.md             # Ce fichier
```