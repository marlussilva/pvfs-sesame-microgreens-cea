# An Open-Architecture Precision Vertical Farming System for Sesame Microgreens: Audit-Ready Telemetry for Dynamic Lighting and Energy--Biomass Benchmarking

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Python](https://img.shields.io/badge/python-3.8%2B-blue)](https://www.python.org/)
[![Dart](https://img.shields.io/badge/dart-3.0%2B-0175C2)](https://dart.dev/)
[![Flutter](https://img.shields.io/badge/flutter-3.0%2B-02569B)](https://flutter.dev/)

This repository provides the **source code** and **analysis scripts** supporting the manuscript:

> **An Open-Architecture Precision Vertical Farming System for Sesame Microgreens: Audit-Ready Telemetry for Dynamic Lighting and Energy--Biomass Benchmarking**
>
> 
>
> **Affiliation:** Laboratory of Advanced Studies in Vertical Agriculture, Goiano Federal Institute of Education, Science and Technology, Rio Verde, Brazil.

The study reports the development and validation of a multi-layer **Precision Vertical Farming System (PVFS)** integrating an IoT-enabled growth chamber, **MQTT** communication, a **document-oriented database** (MongoDB), and **Python-based** statistical and multivariate analyses for sesame microgreens.

---

## 📑 Contents

1. [Repository Structure](#1-repository-structure)
2. [Software Components (PVFS Architecture)](#2-software-components-pvfs-architecture)
3. [Experimental Design & Data](#3-experimental-design-and-data-organization)
4. [Statistical Analysis (Python)](#4-statistical-analysis-python)
5. [Reproducibility Workflow](#5-reproducibility-workflow)
6. [Data and Code Availability](#6-data-and-code-availability)
7. [License and Contact](#7-license-and-contact)

---

## 1. Repository Structure

```text
.
├── software/
│   ├── aplicacao_cliente_hibrida/  # Hybrid client application (Flutter/Dart)
│   ├── my_api/                     # REST API (Dart Shelf + MongoDB)
│   ├── my_mqtt_server/             # MQTT control/bridge service (Dart)
│   └── esp32_firmware/             # ESP32 firmware (Arduino/C++)
│
├── analysis/
│   └── python/
│       ├── estatistica.py          # Two-factor ANOVA, winsorization, CLD bar plots
│       ├── estatistica_txt.py      # Text/Excel-oriented summaries and tables
│       ├── pca.py                  # PCA, correlation analysis, LaTeX-ready tables
│       └── *.csv, *.xlsx           # Input tables consumed by the scripts
│
└── data/
    └── Energy.xlsx                 # Raw energy-use dataset (Voltage, Current, Power, Energy)


## 2. Software Components (PVFS Architecture)

The PVFS adopts a five-layer architecture — Physical, Devices, Infrastructure, Protocols, and Application — to organize sensing/actuation, backend services, communication, and user interfaces.

## 2.1 Physical and Devices layers (software/esp32_firmware/)

ESP32-based nodes integrate:

Environmental sensing: air temperature, relative humidity, and CO₂

Electrical monitoring: voltage, current, power, energy, and power factor (e.g., PZEM-004T)

Timekeeping: DS3231 real-time clock with NTP synchronization (fallback strategy)

Actuation: MCP4725 DAC for LED dimming and relays for auxiliary loads

Optional local storage: microSD for redundant logging (when enabled)

The firmware is written in Arduino/C++ and uses non-blocking scheduling with ESP32 task support (Arduino core/FreeRTOS) to ensure continuous acquisition and deterministic LED dimming without timing conflicts.

## 2.2 Infrastructure layer (software/my_api/, software/my_mqtt_server/)

The infrastructure layer includes:

MongoDB — document-oriented storage for raw and aggregated time-series records.
Typical collections store:

environmental variables (temperature, RH, CO₂);

electrical variables (power, energy, power factor);

LED setpoints and PPFD-related parameters.

MQTT broker — lightweight publish/subscribe communication between ESP32 nodes and backend services.
The topic hierarchy separates telemetry, commands, and logging.

These services are typically deployed via Docker (e.g., Docker Compose).

## 2.3 Protocols layer (software/my_mqtt_server/, software/my_api/)

DartMQTT Control (software/my_mqtt_server/)
MQTT client/service written in Dart responsible for:

subscribing to telemetry topics from ESP32 nodes;

publishing control commands (e.g., lighting profiles);

basic validation, session handling, and buffering;

aggregating data over short windows before persistence.

DartServer Shelf API (software/my_api/)
REST + WebSocket API implemented in Dart (Shelf framework), used to:

expose endpoints for querying MongoDB time-series data;

stream real-time monitoring via WebSockets;

manage experiment metadata (treatments, profiles, lighting spectra).

## 2.4 Application layer (software/aplicacao_cliente_hibrida/)

IoT Vertical Farm Manager (Flutter/Dart hybrid client)

Key features:

real-time visualization of:

PPFD / dimming level (%),

air temperature and relative humidity,

CO₂ concentration,

electrical variables (power, energy, power factor);

configuration and scheduling of lighting profiles:

constant lighting,

Gaussian-modulated lighting (μ, σ, min/max PPFD);

experiment management:

registration of treatments, dates, and profiles;

export of time-series/aggregated data as CSV/JSON for analysis.

## 3. Experimental Design and Data Organization

The growth-chamber experiment followed a 2 × 4 factorial design:

Profiles: Constant PPFD; Gaussian-modulated PPFD

Spectral qualities: Blue, White, Red, and RBW (red + blue + white)

All treatments used a 12 h photoperiod with equal daily light integral (DLI) targets. Physiological traits (e.g., fresh/dry mass, pigments, fluorescence parameters) and energy-related metrics were evaluated at predefined sampling dates (see manuscript for details).

## 3.1 data/ — Energy-use dataset
data/
  Energy.xlsx


This spreadsheet is used to derive the energy-use metrics reported in the manuscript, including (as applicable):

energy consumption per area;

biomass per area (e.g., g m⁻²);

energy–biomass efficiency (e.g., g kWh⁻¹) and related indicators;

intermediate variables/formulas used to obtain final values.

## 3.2 analysis/python/ — Scripts and statistical input tables

The analysis/python/ directory includes:

Python scripts for:

data inspection and checks,

winsorization,

two-factor ANOVA and Tukey HSD,

PCA and correlation analyses,

text/Excel-oriented summaries;

CSV/XLSX input tables consumed directly by the scripts:

trait-by-treatment matrices for factorial analysis,

processed trait tables used in PCA,

auxiliary mapping tables (e.g., treatment codes, light labels).

## 4. Statistical Analysis (Python)

All statistical and multivariate analyses reported in the manuscript were implemented in Python 3.

## 4.1 analysis/python/estatistica.py

Main tasks:

load processed tables (CSV/XLSX);

optionally apply winsorization (IQR-based) to mitigate extreme values;

perform two-factor ANOVA (Profile × Light) per response variable;

run Tukey HSD post-hoc tests when main effects or interactions are significant (α = 0.05);

generate bar plots with:

means ± standard error (SE),

compact letter display (CLD) for multiple comparisons,

uppercase letters comparing Profiles within each Light,

lowercase letters comparing Lights within each Profile;

save TXT/CSV summaries, logs, and plots in output folders created by the script.

## 4.2 analysis/python/estatistica_txt.py

Main tasks:

export text-oriented and tabular outputs, including:

ANOVA tables,

treatment means, SE, and coefficients of variation (CV%),

CLD letters per trait;

generate Excel-friendly summaries when enabled.

## 4.3 analysis/python/pca.py

Main tasks:

preprocessing:

select traits included in PCA,

center and z-score standardize variables;

PCA:

compute eigenvalues and explained variance,

export treatment scores and trait loadings,

generate LaTeX-ready tables (as configured);

correlation analysis:

Pearson correlations among traits and with PCs,

export correlation matrices and supporting tables.

Outputs are saved to script-defined directories (e.g., resultados_pca_cor/) under analysis/python/ or as configured in script headers.

## 5. Reproducibility Workflow
## 5.1 Clone the repository
git clone https://github.com/marlussilva/pvfs-sesame-microgreens-cea.git
cd pvfs-sesame-microgreens-cea


If this repository uses git submodules, initialize them with:

git submodule update --init --recursive

## 5.2 Create and activate a Python environment
python -m venv .venv
source .venv/bin/activate      # Linux/macOS
# .venv\Scripts\activate       # Windows (PowerShell)

## 5.3 Install dependencies

Preferably:

pip install -r requirements.txt


If requirements.txt is not available, install the core scientific stack used by the scripts:

pip install pandas numpy scipy statsmodels matplotlib scikit-learn


Add extra packages only if a script explicitly imports them.

## 5.4 Run the analyses
python analysis/python/estatistica.py
python analysis/python/estatistica_txt.py
python analysis/python/pca.py

## 5.5 Outputs

Outputs (TXT/CSV/XLSX and any figures) are written to the result folders created by each script (e.g., resultados/, resultados_pca_cor/) or to paths configured at the top of each script.

6. Data and Code Availability

This repository contains:

PVFS software components (client app, API, MQTT control services, ESP32 firmware);

Python scripts used for statistical and multivariate analyses;

the energy-use dataset (data/Energy.xlsx);

processed statistical input tables used by ANOVA/Tukey and PCA (analysis/python/).

If additional raw telemetry or large datasets are not included due to size or privacy constraints, they may be shared upon reasonable academic request.

For the final published article, a frozen snapshot of code/data may be archived in a research repository (e.g., Zenodo/OSF/Figshare) with a citable DOI. If/when available, the DOI and the corresponding GitHub release/tag will be added here.

7. License and Contact
License

This repository is licensed under the MIT License. See LICENSE
.

Corresponding author

Marlus Dias Silva
Goiano Federal Institute of Education, Science and Technology, Rio Verde, Brazil
E-mail: marlus.silva@ifgoiano.edu.br

Please cite the associated manuscript/article when using this code or data in scientific publications.

