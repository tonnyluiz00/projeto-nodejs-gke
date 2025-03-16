# projeto-nodejs-gke
# Implantação Contínua com Terraform, Kubernetes, Docker, GitHub e Cloud Build

Este guia de passo a passo demonstra como configurar uma pipeline de implantação contínua (CI/CD) usando Terraform, Kubernetes, Docker, GitHub e Google Cloud Build.

## Pré-requisitos

* Conta do Google Cloud Platform (GCP)
* Docker instalado
* Repositório no GitHub
* Terraform instalado
* Cluster GKE instalado
* Repositório de exemplo: [https://github.com/camilla-m/descomplicando-devops](https://github.com/camilla-m/descomplicando-devops)

## Passo 1: Criar cluster GKE com Terraform

1.  Acesse o Cloud Shell.
2.  Crie uma pasta chamada `terraform`:

    ```bash
    mkdir terraform
    ```
3.  Crie um arquivo chamado `main.tf`:

    ```bash
    cd terraform
    touch main.tf
    ```
4.  Insira as seguintes informações dentro de `main.tf`:

    ```terraform
    terraform {
      required_providers {
        google = {
          source  = "hashicorp/google"
          version = ">= 4.0.0"
        }
      }
    }

    provider "google" {
      project = "seu-projeto-gcp-id" # Substitua pelo ID do seu projeto
      region  = "us-central1"           # Substitua pela região desejada
    }

    resource "google_container_cluster" "my_autopilot_cluster" {
      name     = "cluster-us-central1-nodejs"
      location = "us-central1" # ou sua região desejada
      enable_autopilot = true
    }
    ```
5.  Execute os comandos Terraform:

    ```bash
    terraform init
    terraform plan
    terraform apply
    ```
6.  Quando o cluster estiver pronto, execute o seguinte comando no Cloud Shell:

    ```bash
    gcloud container clusters get-credentials cluster-us-central1-nodejs \
        --location us-central1
    ```

## Passo 2: Configurar a pipeline no GCP

1.  Crie um arquivo `cloudbuild.yaml` na pasta raiz do seu projeto com o seguinte conteúdo:

    ```yaml
    steps:
      # Build the Docker image
      - name: 'gcr.io/cloud-builders/docker'
        args: ['build', '-t', 'us-central1-docker.pkg.dev/$PROJECT_ID/hello-repo/cicd-nodejs:1.0', '.']
      # Push the Docker image to Artifact Registry
      - name: 'gcr.io/cloud-builders/docker'
        args: ['push', 'us-central1-docker.pkg.dev/$PROJECT_ID/hello-repo/cicd-nodejs:1.0']
      # Deploy to GKE
      - name: 'gcr.io/cloud-builders/kubectl'
        args: ['rollout', 'restart', 'deployment', 'helloworld-gke']
        env:
          - CLOUDSDK_CONTAINER_CLUSTER=cluster-us-central1-nodejs
          - CLOUDSDK_COMPUTE_ZONE=us-central1-a
          - CLOUDSDK_COMPUTE_REGION=us-central1
    options:
      logging: CLOUD_LOGGING_ONLY
    ```
2.  Certifique-se de substituir `cicd-nodejs` pelo nome da imagem Docker que você definiu e `helloworld-gke` pelo nome desejado para o serviço no Kubernetes.
3.  Substitua `$PROJECT_ID` pelo ID do seu projeto no GCP.
4.  Salve o arquivo `cloudbuild.yaml`.

## Passo 3: Configurar a integração com o GitHub

1.  No Google Cloud Console, vá para o serviço Cloud Build e selecione "Gatilhos".
2.  Clique em "Configurar conexão" e siga as instruções para conectar sua conta do GitHub.
3.  Selecione o repositório do GitHub que contém sua aplicação NodeJS.

## Passo 4: Ativar a pipeline de implementação automática

1.  No Google Cloud Console, vá para o serviço Cloud Build e selecione "Gatilhos".
2.  Clique em "Criar gatilho" para criar um novo gatilho.
3.  Defina as condições de acionamento do gatilho (por exemplo, quando houver alterações na branch principal do repositório do GitHub).
4.  Escolha a opção "Detecção automática" para usar o arquivo de configuração `cloudbuild.yaml` que você criou anteriormente.
5.  Clique em "Criar" para criar o gatilho.
6.  Agora, quando você fizer push para a branch principal do seu repositório do GitHub, a pipeline do Google Cloud Build será acionada. Ela construirá a imagem Docker, fará o push para o Artifact Registry e implantará no GKE.

## Passo 5: Deploy e serviço no Kubernetes

1.  Execute `kubectl apply -f deployment.yaml` e `kubectl apply -f service.yaml` do repositório do GitHub.
2.  Verifique se o nome do repositório do Artifact Registry, o ID do projeto e a imagem estão corretos no arquivo `deployment.yaml`.
3.  Obtenha o IP externo do serviço recém-criado e acesse `http://EXTERNAL-IP`.

    ```bash
    kubectl get pods
    kubectl apply -f service.yaml
    kubectl get svc
    kubectl get svc # Novamente para obter o IP externo
    ```

## Passo 6: Executar o Cloud Build novamente

1.  Faça uma alteração no arquivo `server.js` (por exemplo, na mensagem do GET) e faça push para o repositório.
2.  Acompanhe a execução do Cloud Build.
3.  No Cloud Shell, execute `kubectl get pods` para monitorar a substituição do pod antigo pelo novo.

Este README fornece um guia completo para configurar sua pipeline de CI/CD. Lembre-se de substituir os valores de exemplo pelos seus próprios valores de projeto e configuração.