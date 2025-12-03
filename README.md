# Demo Infrastructure Repository

Welcome to **demo-infra** — a modern Infrastructure as Code (IaC) repository demonstrating GitOps best practices using **Azure Bicep** and **GitHub Actions**. This project is designed as an educational resource for cloud engineering bootcamp students to learn how to manage cloud infrastructure through code and automation.

## 📚 What You'll Learn

This repository teaches you:
- **Infrastructure as Code (IaC)**: Define Azure resources in code instead of manual portal clicks
- **GitOps**: Automate infrastructure deployment through Git workflows (PR validation → merge → auto-deploy)
- **Azure Bicep**: Write clean, maintainable ARM templates with Bicep
- **CI/CD Automation**: Use GitHub Actions to validate and deploy infrastructure safely
- **Multi-App Architecture**: Manage multiple applications/components in a single repository
- **Security Best Practices**: Handle secrets, tokens, and credentials safely in CI/CD

---

## 🏗️ Repository Structure

```
demo-infra/
├── .github/
│   └── workflows/
│       ├── pull-request.yaml          # PR validation workflow
│       └── build.yaml                 # Deployment workflow (on merge to main)
├── demo-helloworld-app/               # Example application infrastructure
│   ├── main.bicep                     # Entry point: defines the full deployment
│   ├── parameters.dev.json            # Environment-specific parameters (dev)
│   └── modules/
│       ├── resourcegroup.bicep        # Helper: outputs current RG info
│       ├── managedEnvironment.bicep   # Azure Container Apps managed environment
│       └── containerapp.bicep         # Container app definition
└── README.md                          # This file
```

---

## 🚀 Quick Start

### Prerequisites

Before you begin, install:
- **Azure CLI**: [Install guide](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli)
- **Bicep CLI**: Included with Azure CLI or install via:
  ```bash
  az bicep install
  ```
- **Git** and a GitHub account

### 1. Local Setup

Clone the repository:
```bash
git clone https://github.com/khensel17/demo-infra.git
cd demo-infra
```

Authenticate with Azure:
```bash
az login
az account set --subscription <YOUR_SUBSCRIPTION_ID>
```

### 2. Validate Bicep Locally

Lint all Bicep files:
```bash
az bicep lint --file demo-helloworld-app/main.bicep
find demo-helloworld-app -name "*.bicep" -exec az bicep lint --file {} \;
```

Compile Bicep to ARM JSON template:
```bash
az bicep build --file demo-helloworld-app/main.bicep
# Generates: demo-helloworld-app/main.json
```

### 3. Preview Deployment (Validate)

Before deploying, validate the template against Azure:
```bash
az deployment group validate \
  --resource-group rg-test \
  --template-file demo-helloworld-app/main.json \
  --parameters @demo-helloworld-app/parameters.dev.json
```

### 4. Deploy to Azure

Create a resource group (if it doesn't exist):
```bash
az group create \
  --name rg-demo-helloworld-app \
  --location westeurope
```

Deploy the infrastructure:
```bash
az deployment group create \
  --resource-group rg-demo-helloworld-app \
  --template-file demo-helloworld-app/main.bicep \
  --parameters @demo-helloworld-app/parameters.dev.json
```

Monitor deployment:
```bash
# View deployment status
az deployment group show \
  --resource-group rg-demo-helloworld-app \
  --name main

# View deployment details
az deployment operation group list \
  --resource-group rg-demo-helloworld-app \
  --deployment-name main
```

---

## 🔄 GitHub Actions Workflows

### Pull Request Workflow (`pull-request.yaml`)

**Triggered on:** Every pull request to `main`

**What it does:**
1. ✅ **Bicep Lint** — Validates syntax and style for all `.bicep` files
2. ✅ **Bicep Build** — Compiles Bicep to ARM JSON, fails if compilation errors
3. 📦 **Upload Artifacts** — Stores compiled templates for review

**Purpose:** Catch infrastructure errors *before* they reach `main` branch. Acts as a gate to ensure code quality.

**Example PR flow:**
1. Create a feature branch and modify `demo-helloworld-app/main.bicep`
2. Push to GitHub and open a pull request
3. GitHub Actions automatically runs validation
4. If validation fails, review the error and fix
5. Once validation passes, you can merge

### Deployment Workflow (`build.yaml`)

**Triggered on:** Push to `main` branch (i.e., after PR merge)

**What it does:**
1. 🔐 Authenticates with Azure (uses local `az login` via self-hosted runner)
2. 🔑 Substitutes secrets (replaces `REPLACE_WITH_SECURE_TOKEN` with actual token)
3. ✅ **Lint & Build** — Validates Bicep before deployment
4. 🚀 **Deploy** — Creates resource groups and deploys infrastructure

**Purpose:** Automatically deploy validated infrastructure to Azure when changes are merged.

**Workflow principle (GitOps):**
```
Developer → Git Push → PR Validation → Code Review → Merge → Auto-Deploy
```

---

## 🔐 Secrets Management

### Setting Up Secrets

1. Go to GitHub repository → **Settings** → **Secrets and variables** → **Actions**
2. Add required secrets:

| Secret Name | Value | Purpose |
|------------|-------|---------|
| `DOCKERHUB_TOKEN` | Your Docker Hub personal access token | Authenticate to Docker Hub for pulling container images |
| `DOCKERHUB_USERNAME` | Your Docker Hub username | Reference in container app config |

### Secret Substitution

The deployment workflow uses `envsubst` to safely substitute placeholders:
```yaml
- name: Substitute secure token in parameters file
  env:
    DOCKERHUB_TOKEN: ${{ secrets.DOCKERHUB_TOKEN }}
  run: |
    envsubst < demo-helloworld-app/parameters.dev.json > demo-helloworld-app/parameters.dev.substituted.json
    mv demo-helloworld-app/parameters.dev.substituted.json demo-helloworld-app/parameters.dev.json
```

**Key principle:** Secrets are never committed to Git. They're injected at deployment time.

---

## 📝 Infrastructure Modules Explained

### `main.bicep` — Orchestration Layer

This is the entry point that coordinates all resources. It:
- Accepts parameters (app name, container image, resources)
- Calls modules in dependency order
- Outputs resource IDs and properties

**Key concepts:**
```bicep
module managedEnvironmentDeploy './modules/managedEnvironment.bicep' = {
  name: 'managedEnvironmentDeploy'
  params: {
    name: containerAppEnvName
    location: resourceGroupDeploy.outputs.resourceGroupLocation
  }
}
```

### `modules/resourcegroup.bicep` — RG Info

Returns information about the target resource group (ID, name, location). This avoids hardcoding resource group references.

**Best practice:** Always parameterize resource group info rather than hardcoding.

### `modules/managedEnvironment.bicep` — Container Apps Environment

Creates an **Azure Container Apps Managed Environment**:
- Hosts container apps with built-in networking
- Supports consumption-based workload profiles
- Configured with public network access enabled

### `modules/containerapp.bicep` — Application Deployment

Defines the container app:
- Image source (Docker Hub)
- Resource allocation (CPU, memory)
- Ingress configuration (network access, port 3000)
- Environment variables and secrets management
- Support for custom application environment variables

---

## 🎯 Parameters & Customization

### Environment Parameters (`parameters.dev.json`)

Configure infrastructure for different environments:

```json
{
  "parameters": {
    "containerAppEnvName": { "value": "demo-env" },
    "containerAppName": { "value": "demo-helloworld-app" },
    "containerImage": { "value": "docker.io/khensel/demo-helloworld-app:latest" },
    "dockerHubUsername": { "value": "your-username" },
    "dockerHubToken": { "value": "REPLACE_WITH_SECURE_TOKEN" },
    "cpuCores": { "value": "0.25" },
    "memoryGiB": { "value": "0.5" },
    "environmentVariables": [{ "name": "ENV", "value": "VALUE" }]
  }
}
```

**To deploy to different environments:**
1. Create `parameters.prod.json` with production settings
2. Update deployment step to use the desired parameters file
3. Manage different resource groups per environment

---

## 🛠️ Common Tasks

### Add a New Application

1. Create directory:
   ```bash
   mkdir -p another-app/modules
   ```

2. Create `another-app/main.bicep` (follow `demo-helloworld-app/main.bicep` as template)

3. Create `another-app/parameters.dev.json` with your parameters

4. Update `.github/workflows/pull-request.yaml` and `build.yaml`:
   ```yaml
   strategy:
     matrix:
       app:
         - demo-helloworld-app
         - another-app  # Add this
   ```

5. Push to a feature branch and test via pull request

### Update Container Image

1. Edit `parameters.dev.json`:
   ```json
   "containerImage": { "value": "docker.io/your-org/new-image:v2" }
   ```

2. Create a pull request, validate, merge
3. Deployment workflow automatically updates the running app

### Scale Resources

Change CPU/memory in `parameters.dev.json`:
```json
"cpuCores": { "value": "1" },
"memoryGiB": { "value": "2" }
```

---

## 📊 Best Practices Demonstrated

### ✅ Code Quality
- **Bicep Linting** on all pull requests ensures consistency
- **Modular design** with separate concerns in different files
- **Parameter validation** before deployment

### ✅ Security
- **No hardcoded secrets** — all credentials use GitHub Secrets
- **Secure token substitution** via `envsubst`
- **Principle of least privilege** — use minimal resource permissions

### ✅ GitOps
- **All infrastructure in code** — source of truth is Git
- **Automated validation** — catch errors before merge
- **Automated deployment** — reduce manual steps
- **Audit trail** — Git history shows who changed what, when

### ✅ Reliability
- **Modular templates** — reusable, testable components
- **Environment parity** — same code deploys to dev/staging/prod
- **Reproducible builds** — compile Bicep to ARM JSON for consistency

### ✅ Scalability
- **Matrix strategy** — easily add more applications
- **Parameterized templates** — support multiple environments
- **Resource naming conventions** — consistent, predictable names

---

## 📚 Learning Resources

### Azure & Bicep
- [Azure Bicep Documentation](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/)
- [Bicep Best Practices](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/best-practices)
- [Azure Container Apps Docs](https://learn.microsoft.com/en-us/azure/container-apps/)

### GitHub Actions
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Workflow Syntax Reference](https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions)

### GitOps & Infrastructure as Code
- [GitOps Principles](https://opengitops.dev/)
- [Infrastructure as Code Best Practices](https://www.hashicorp.com/blog/infrastructure-as-code-best-practices)

---

## 🐛 Troubleshooting

### "Bicep lint failed"
- Run locally: `az bicep lint --file demo-helloworld-app/main.bicep`
- Fix syntax errors and try again

### "Deployment validation failed"
- Ensure parameters match the expected types (strings vs integers)
- Check resource quotas and limits in your Azure subscription
- Verify you're deploying to the correct region

### "Container app not accessible"
- Check ingress configuration in `containerapp.bicep`
- Verify Docker image is public or credentials are correctly configured
- Review container app logs in Azure Portal

### "Secrets not being substituted"
- Verify `DOCKERHUB_TOKEN` secret is set in GitHub Actions settings
- Check the `envsubst` command syntax in the workflow
- Ensure environment variable is exported before running `envsubst`

---

## 📝 Recommended Exercises for Students

### Exercise 1: Deploy and Explore
1. Clone this repo and follow the Quick Start section
2. Deploy the demo app to your Azure subscription
3. Explore the created resources in the Azure Portal
4. Compare the deployed resources to the Bicep template

### Exercise 2: Modify Parameters
1. Create a new parameters file `parameters.staging.json`
2. Update the resource names and sizing for a staging environment
3. Validate and deploy to a new resource group
4. Observe differences in resource configuration

### Exercise 3: Extend the Infrastructure
1. Add a new module (e.g., App Insights for monitoring)
2. Update `main.bicep` to use the new module
3. Create a pull request and verify validation passes
4. Merge and observe auto-deployment

### Exercise 4: CI/CD Pipeline
1. Create a feature branch and modify container app resources
2. Push to GitHub and open a pull request
3. Watch GitHub Actions validate your changes
4. Fix any errors and see validation pass
5. Merge and observe auto-deployment to Azure

---

## 🤝 Contributing

This is an educational repository. Contributions and improvements are welcome!

1. Create a feature branch
2. Make your changes
3. Push and open a pull request
4. Ensure all GitHub Actions checks pass
5. Request review and merge

---

## 📄 License

This project is provided as-is for educational purposes.

---

## ❓ Questions?

- 📖 Review the [Bicep documentation](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/)
- 💬 Check GitHub Issues in this repository
- 🎓 Consult with your bootcamp instructors

**Happy learning and deploying! 🚀**
