# Voting App Deployment Pipeline

This project sets up a complete CI/CD pipeline to deploy a voting application using various DevOps tools and AWS services.

## 📌 Tools & Technologies Used

- **Packer**: To create a custom Amazon Machine Image (AMI) with Docker and Node Exporter pre-installed.
- **Terraform**: To provision infrastructure on AWS.
- **AWS Services**:
  - **RDS**: Managed database service for persistent storage.
  - **ElastiCache**: Redis caching service to optimize performance.
  - **CloudFront**: For content delivery and caching.
  - **EC2**: Two instances to deploy the application servers.
  - **Auto Scaling Group** & **Load Balancer**: To ensure high availability and scalability.
  - **ECR**: For storing Docker images.
- **GitHub Actions**: To automate the CI/CD pipeline.
- **Prometheus & Grafana**: For real-time monitoring of instances using Node Exporter.

---

## 📖 Project Workflow

1. **Store Everything in GitHub Repository**
   - All infrastructure code (Terraform, Packer) and application code are version-controlled in the GitHub repository.

2. **Trigger Pipeline on Code Changes**
   - Any change pushed to the repository triggers the CI/CD pipeline via GitHub Actions.

3. **Run Terraform to Provision Infrastructure**
   - Terraform is executed to set up or update the AWS infrastructure automatically.

4. **Build a Custom AMI with Packer**
   - Packer runs to create an AMI with Docker and Node Exporter pre-installed.

5. **Build and Push Docker Images to AWS ECR**
   - The latest application code is containerized and pushed to Amazon Elastic Container Registry (ECR).

6. **Deploy Updated Containers to EC2 Instances**
   - The updated application containers are deployed to the running EC2 instances.

7. **Monitor Instances with Prometheus & Grafana**
   - Node Exporter collects metrics from EC2 instances.
   - Grafana visualizes system performance.

---

## 🚀 Getting Started

### Prerequisites

Ensure you have the following installed on your local machine:

- Packer
- Terraform
- AWS CLI
- Docker
- GitHub CLI (optional)

### Setup Instructions

1. **Clone the Repository**
   ```bash
   git clone https://github.com/yourusername/voting_app_pipeline.git
   cd voting_app_pipeline
   ```

2. **Build the AMI with Packer**
   ```bash
   packer build packer-template.json
   ```

3. **Deploy Infrastructure with Terraform**
   ```bash
   terraform init
   terraform apply -auto-approve
   ```

4. **Push Docker Images to AWS ECR**
   ```bash
   docker build -t your-ecr-repo-name .
   docker tag your-ecr-repo-name:latest <aws-account-id>.dkr.ecr.<region>.amazonaws.com/your-ecr-repo-name:latest
   docker push <aws-account-id>.dkr.ecr.<region>.amazonaws.com/your-ecr-repo-name:latest
   ```

5. **Monitor the System**
   - Access Grafana and Prometheus dashboards to monitor performance.

---

## 🎯 Future Improvements

- Implement Blue-Green or Canary deployments.
- Add security best practices (IAM roles, security groups, etc.).
- Automate scaling rules based on load.

---

## 🛠️ Contributing

Contributions are welcome! Feel free to open issues and submit pull requests.

---

## 📜 License

This project is licensed under the MIT License.

