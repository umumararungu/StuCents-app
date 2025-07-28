## StuCents Full Continuous Deployment (CD) Flow Documentation

### Overview

The Continuous Deployment (CD) process for the **StuCents** project automates the full application lifecycle—from code commit to production deployment—integrating testing, security, logging, and release management in a secure and observable way.

---

### 1. Pipeline Stages (CI → CD Flow)

| Stage               | Description                                                         |
| ------------------- | ------------------------------------------------------------------- |
| **CI Trigger**      | Triggered on `push` or PR merge to `main` branch                    |
| **Build**           | Container image is built using Docker or Azure build                |
| **Test**            | Runs unit/integration tests ( `npm test`)                      |
| **Security Scans**  | Runs dependency (`Snyk`) and container scans (`Trivy`)              |
| **Image Push**      | Pushes tagged image to Azure Container Registry (ACR)               |
| **Deployment**      | Terraform automates deployment to Azure Container App               |
| **Post-Deployment** | Logs streamed to Log Analytics + Alerts triggered on error keywords |

---

### 2. DevSecOps Integration

| Tool               | Purpose                                               |
| ------------------ | ----------------------------------------------------- |
| **Snyk**           | Checks for Node.js dependency vulnerabilities         |
| **Trivy**          | Scans Docker container images for CVEs                |
| **GitHub Actions** | Integrated security scanning in CI/CD pipeline        |
| **Secrets**        | Stored securely in GitHub (`AZURE_CREDENTIALS`) |

**Sample GitHub Action Security Scan Step:**

```yaml
- name: Run Trivy vulnerability scanner
  uses: aquasecurity/trivy-action@v0.13.0
  with:
    image-ref: ${{ env.REGISTRY_LOGIN_SERVER }}/stucents-app:${{ github.sha }}
```

---

### 3. Monitoring & Observability

| Component                   | Function                                        |
| --------------------------- | ----------------------------------------------- |
| **Log Analytics Workspace** | Central logging for the Container App           |
| **Console Logs Query**      | KQL used: `ContainerAppConsoleLogs_CL`          |
| **Azure Dashboard**         | Live view of latest logs via pinned KQL tile    |
| **Alerts**                  | Triggered on logs containing the word `"error"` |

---

### 4. Alerting & Release Dashboard

- **Log Alert Rule**: Custom log search looks for `"error"` in logs and triggers email notification.
- **Dashboard**: Displays recent logs using KQL pinned tile.

---

### 5. Release Management

| Practice                 | Description                                    |
| ------------------------ | ---------------------------------------------- |
| **Conventional Commits** | All commits follow format like `feat:`, `fix:` |
| **CHANGELOG.md**         | Updated on every release                       |
| **Versioning**           | Semantic versioning: `v1.0.0`, `v1.0.1`.  |
| **GitHub Releases**      | Tags tied to each change with descriptions     |

**Example CHANGELOG Entry:**

```md
## [1.1.0] - 2025-07-28
### Added
- Dashboard view for transaction history
- Log-based error alerts

### Fixed
- Resolved MongoDB URI misconfiguration
```

---

### CD Flow Summary

| Feature                      | Status |
| ---------------------------- | ------ |
| Fully Automated CI/CD        | Done   |
| Auto Deployment on Merge     | Done   |
| Security Scans in Pipeline   | Done   |
| Container Registry with ACR  | Done   |
| Azure Container App Deployed | Done   |
| Logs Sent to Log Analytics   | Done   |
| Alerts Configured            | Done   |
| CHANGELOG & Versioning       | Done   |

