#!/usr/bin/env bash
set -euo pipefail

#############################################
# CONFIGURAÇÕES BÁSICAS
#############################################

# Nome do diretório/repositório local
REPO_NAME="pvfs-sesame-microgreens-cea"

# Opcional: URL do remoto no GitHub (altere se quiser usar HTTPS)
# - Deixe em branco ("") se ainda não criou o repositório remoto
REMOTE_URL="git@github.com:marlussilva/${REPO_NAME}.git"

# URLs dos três repositórios existentes
REPO_CLIENTE="https://github.com/marlussilva/aplicacao_cliente_hibrida.git"
REPO_API="https://github.com/marlussilva/my_api.git"
REPO_MQTT="https://github.com/marlussilva/my_mqtt_server.git"

#############################################
# CRIA DIRETÓRIO E INICIALIZA GIT
#############################################

if [ -d "$REPO_NAME" ]; then
  echo "Diretório '$REPO_NAME' já existe. Saindo para não sobrescrever nada."
  exit 1
fi

mkdir -p "$REPO_NAME"
cd "$REPO_NAME"

echo "Inicializando repositório Git em $(pwd)..."
git init
git branch -M main || true

#############################################
# ESTRUTURA DE PASTAS
#############################################

echo "Criando estrutura de pastas..."

mkdir -p software
mkdir -p analysis/python
mkdir -p data/raw
mkdir -p data/processed
mkdir -p figures
mkdir -p docs

#############################################
# .gitignore
#############################################

cat > .gitignore << 'EOF'
# Python
__pycache__/
*.pyc
.venv/
venv/
env/

# Dados pesados / intermediários
data/raw/*
data/processed/*
!data/raw/README.md
!data/processed/README.md

# Resultados gerados por scripts
resultados/
resultados_pca_cor/

# IDEs / Sistema
.vscode/
.idea/
.DS_Store
Thumbs.db
EOF

#############################################
# README.md BÁSICO
#############################################

cat > README.md << 'EOF'
# Precision Vertical Farming System for Sesame Microgreens – Companion Repository

This repository contains the companion code and analysis scripts for the manuscript:

> Precision Vertical Farming System for Sesame Microgreens: Development of a Smart Growth Chamber  
> (submission to *Computers and Electronics in Agriculture*).

## Structure

- `software/`  
  - `aplicacao_cliente_hibrida/` – Hybrid client application (Flutter/Dart).
  - `my_api/` – REST API (Dart shelf + MongoDB).
  - `my_mqtt_server/` – MQTT control server.

- `analysis/python/`  
  Python scripts for:
  - Two-way ANOVA with winsorization and bar plots.
  - Text reports, croquis, and summary tables.
  - PCA, correlation plots, and LaTeX tables.

- `data/raw/` and `data/processed/`  
  Raw and processed datasets used in the analyses (not tracked by Git by default).

- `figures/`  
  Figures generated for the manuscript.

- `docs/`  
  Additional documentation and notes.

EOF

#############################################
# README PARA PASTAS DE DADOS
#############################################

cat > data/raw/README.md << 'EOF'
Raw experimental datasets (original measurements). 
Not tracked by Git by default. Place here the files that should NOT go to the public repository.
EOF

cat > data/processed/README.md << 'EOF'
Processed datasets used directly in the statistical analyses and figures.
You can track selected CSV files here if they are safe to publish.
EOF

#############################################
# SUBMÓDULOS (SOFTWARE PRINCIPAL)
#############################################

echo "Adicionando submódulos (isso requer acesso aos repositórios do GitHub)..."

set +e
git submodule add "$REPO_CLIENTE" software/aplicacao_cliente_hibrida || echo "Aviso: não foi possível adicionar aplicacao_cliente_hibrida (verifique acesso/permite)."
git submodule add "$REPO_API"     software/my_api                    || echo "Aviso: não foi possível adicionar my_api (verifique acesso/permite)."
git submodule add "$REPO_MQTT"    software/my_mqtt_server            || echo "Aviso: não foi possível adicionar my_mqtt_server (verifique acesso/permite)."
set -e

#############################################
# PLACEHOLDERS PARA SCRIPTS DE ESTATÍSTICA
#############################################

cat > analysis/python/estatistica.py << 'EOF'
"""
Placeholder for estatistica.py

Here you should paste the real script that performs:
- Two-way ANOVA with winsorization by IQR (Regime × Ligth),
- TXT reports,
- bar plots with SE and letters,
- croquis and Excel summaries.

Original internal filename: estatistica.py
"""
EOF

cat > analysis/python/estatistica_txt.py << 'EOF'
"""
Placeholder for estatistica_txt.py

Here you should paste the real script that performs:
- Two-way ANOVA with winsorization,
- TXT reports focused on tabular outputs and croquis,
- Excel extracts for each variable.

Original internal filename: estatistica_txt.py
"""
EOF

cat > analysis/python/pca.py << 'EOF'
"""
Placeholder for pca.py

Here you should paste the real script that performs:
- PCA with winsorized data,
- PCA biplot with treatments and variables,
- Correlation plots (circles),
- LaTeX table for correlations between variables and PCs.

Original internal filename: pca.py
"""
EOF

#############################################
# PRIMEIRO COMMIT
#############################################

echo "Fazendo primeiro commit..."

git add .
git commit -m "Initial structure for PVFS sesame microgreens companion repository"

#############################################
# CONFIGURA REMOTE (SE DEFINIDO)
#############################################

if [ -n "$REMOTE_URL" ]; then
  git remote add origin "$REMOTE_URL" 2>/dev/null || echo "Remote 'origin' já existe ou não pôde ser adicionado."
  echo
  echo "Remote configurado como: $REMOTE_URL"
  echo "Quando o repositório remoto existir no GitHub, rode:"
  echo "  git push -u origin main"
fi

echo
echo "Pronto! Estrutura criada em '$REPO_NAME'."
echo "Agora copie seus scripts reais para analysis/python/ e ajuste o que for necessário."
