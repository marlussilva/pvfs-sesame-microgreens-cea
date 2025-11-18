# Precision Vertical Farming System for Sesame Microgreens – Companion Repository

This repository contains the companion software and analysis scripts for the manuscript:

> **Precision Vertical Farming System for Sesame Microgreens: Development of a Smart Growth Chamber**  
> Marlus Dias Silva et al.  
> Laboratory of Advanced Studies in Vertical Agriculture, Goiano Federal Institute of Education, Science and Technology, Rio Verde, Brazil.

The study describes the development and validation of a multi-layer Precision Vertical Farming System (PVFS) integrating an IoT-based growth chamber, MQTT communication, a document-oriented database and Python-based statistical and multivariate analysis for sesame microgreens.

---

## 1. Repository structure

```text
software/
  aplicacao_cliente_hibrida/   # Hybrid client application (Flutter/Dart)
  my_api/                      # REST API (Dart shelf + MongoDB)
  my_mqtt_server/              # MQTT control/bridge service
  esp32_firmware/              # Arduino-style C/C++ firmware for ESP32 controllers

analysis/
  python/
    estatistica.py             # Factorial analysis, winsorization, CLD bar plots, TXT/CSV reports
    estatistica_txt.py         # Text/Excel-oriented summaries and croquis
    pca.py                     # PCA, correlation analysis, LaTeX tables
    *.csv, *.xlsx              # Statistical input tables used directly by the Python scripts

data/
  Energy.xlsx                  # Energy-use dataset used to derive g m⁻², g kWh⁻¹ and related metrics


2. Software components (PVFS architecture)

The PVFS adopts a five-layer architecture — Physical, Devices, Infrastructure, Protocols and Application — to organize sensing/actuation, logical services, communication and user interface.

2.1 Physical and Devices layers (software/esp32_firmware/)

ESP32-based controllers integrate:

Environmental sensors: air temperature, relative humidity and CO₂

Electrical monitoring: voltage, current, power, energy and power factor (e.g., PZEM-004T)

Timekeeping: DS3231 real-time clock with NTP synchronization fallback

Actuation: MCP4725 DAC for LED dimming and relays for auxiliary loads

Local storage (optional): microSD for redundant logging

The firmware is written in Arduino-style C/C++ and uses non-blocking task scheduling (e.g., FreeRTOS-style tasks) to ensure continuous acquisition and LED dimming without timing conflicts.

2.2 Infrastructure layer (software/my_api/, software/my_mqtt_server/)

The infrastructure layer is composed of:

MongoDB

Document-oriented storage for raw and aggregated time-series data.

Collections typically store:

Environmental variables (temperature, RH, CO₂),

Electrical variables (power, energy, power factor),

LED setpoints and PPFD-related parameters.

MQTT broker

Lightweight publish/subscribe communication between ESP32 nodes and the backend.

Topic hierarchy separates telemetry, commands and logging.

2.3 Protocols layer (software/my_mqtt_server/, software/my_api/)

DartMQTT Control (software/my_mqtt_server/)

MQTT client written in Dart for:

Subscribing to sensor topics from ESP32 nodes;

Publishing control commands (e.g., LED dimming profiles);

Applying basic validation, session handling and buffering.

DartServer Shelf API (software/my_api/)

REST + WebSocket API implemented in Dart using the Shelf framework.

Main responsibilities:

Expose HTTP endpoints for querying historical data from MongoDB;

Provide WebSocket streams for real-time monitoring;

Offer endpoints for experiment configuration and metadata (treatments, regimes, lighting profiles).

2.4 Application layer (software/aplicacao_cliente_hibrida/)

IoT Vertical Farm Manager (Flutter/Dart hybrid client)

Main features:

Real-time visualization of:

PPFD / dimming level (%);

Air temperature and relative humidity;

CO₂ concentration;

Electrical variables (power, energy, power factor).

Configuration and scheduling of lighting regimes:

Constant lighting;

Gaussian-modulated lighting with user-defined parameters (μ, σ, minimum and maximum PPFD).

Experiment management:

Registration of treatments, dates and regimes;

Export of time-series and aggregated data as CSV/JSON for analysis in Python.

3. Experimental design and data organization

The growth-chamber experiment followed a 2 × 4 factorial design:

Regimes:

Constant PPFD;

Gaussian-modulated PPFD.

Spectral qualities:

Blue, White, Red and RBW (red + blue + white).

All treatments were conducted under a 12 h photoperiod with equal daily light integral (DLI). Physiological traits (e.g., fresh and dry mass, chlorophyll pigments, fluorescence parameters) and energy-related metrics were evaluated at predefined sampling dates.

In this repository, the data are organized as follows.

3.1 data/ – Energy-use dataset

The data/ directory contains only the dataset used to derive the Energy-use metrics reported in the manuscript, for example: 
data/
  Energy.xlsx

This file documents:

Energy consumption per treatment;

Biomass per area (e.g., g m⁻²);

Energy-use efficiency (e.g., g kWh⁻¹) and related indicators;

Intermediate variables or formulas required to obtain the final metrics reported in the main text and tables.

3.2 analysis/python/ – Scripts and statistical input tables

The analysis/python/ directory contains:

All Python scripts used for:

Exploratory data inspection;

Winsorization;

Two-factor ANOVA and Tukey HSD;

PCA and correlation analysis;

Text/Excel-oriented summaries.

The input tables (CSV/XLSX) consumed directly by these scripts, including:

Trait-by-treatment matrices for factorial analysis;

Processed trait tables used in PCA;

Auxiliary mapping tables (e.g., treatment codes, regimes, light colors).

By keeping the statistical inputs in analysis/python/, the repository explicitly links each table to the script that uses it, simplifying reuse and reproducibility.

4. Statistical analysis (Python)

All statistical and multivariate analyses reported in the manuscript were implemented in Python 3.

4.1 analysis/python/estatistica.py

Responsibilities:

Load the relevant processed tables (CSV/XLSX) from analysis/python/;

Optionally apply winsorization based on the interquartile range (IQR) to mitigate the influence of extreme outliers;

Perform two-factor ANOVA (Regime × Light) for each response variable;

Run Tukey HSD post-hoc tests when main effects or the interaction are significant (α = 0.05);

Generate bar plots with:

Means ± standard error (SE);

Compact letter display (CLD) for multiple comparisons;

Uppercase letters to compare Regimes within each Light;

Lowercase letters to compare Lights within each Regime;

Save TXT/CSV summaries, logs and, when applicable, plots in result folders created by the script (e.g., resultados/).

4.2 analysis/python/estatistica_txt.py

Responsibilities:

Produce text-oriented and tabular outputs, including:

ANOVA tables;

Treatment means, standard errors, coefficients of variation (CV);

CLD letters for each trait;

Export croquis and summary tables in TXT and/or Excel-friendly formats.

These outputs are useful for supplementary materials and for cross-checking the numerical results reported in the manuscript.

4.3 analysis/python/pca.py

Responsibilities:

Preprocessing:

Selection of traits included in PCA (e.g., biomass, fluorescence, pigment content, leaf traits);

Centering and z-score standardization of variables.

Principal Component Analysis (PCA):

Computation of eigenvalues and explained variance;

Extraction of principal component scores (treatments) and loadings (traits);

Export of tables summarizing eigenvalues, loadings and scores.

Correlation analysis:

Pearson correlations among traits;

Correlations between traits and PCs;

Generation of correlation matrices and PCA-related outputs suitable for figure generation.

Outputs (tables, TXT/CSV files and any plots created by the script) are saved in subdirectories created by the script (e.g., resultados_pca_cor/) within analysis/python/ or in paths configured inside the script headers.

5. Reproducibility workflow

The following steps illustrate how another researcher can reproduce the main numerical results using this repository.

5.1 Clone the repository and initialize submodules

git clone https://github.com/marlussilva/pvfs-sesame-microgreens-cea.git
cd pvfs-sesame-microgreens-cea
git submodule update --init --recursive

If you prefer SSH, replace the URL accordingly.

data/
  Energy.xlsx


5.3 Create and activate a Python environment
python -m venv .venv
source .venv/bin/activate      # Linux/macOS
# .venv\Scripts\activate       # Windows (PowerShell)


Install the required packages (either from a requirements.txt file, if provided, or manually):
pip install pandas numpy scipy statsmodels matplotlib seaborn scikit-learn
Adjust the list according to the packages actually used in the scripts.

5.4 Run the analyses

# ANOVA, Tukey HSD, bar plots and TXT/CSV summaries
python analysis/python/estatistica.py

# Text/Excel-oriented reports (if applicable)
python analysis/python/estatistica_txt.py

# PCA and correlation analyses
python analysis/python/pca.py

5.5 Outputs

Numerical outputs (TXT, CSV, Excel) are written to the result folders defined in the scripts (e.g., resultados/, resultados_pca_cor/) under analysis/python/.

Any plots generated by the scripts are saved alongside these outputs or in directories specified inside the scripts.


6. Data and code availability statement

The core PVFS software (client application, API, MQTT control services and ESP32 firmware) and the Python scripts used for statistical and multivariate analyses are provided in this GitHub repository.

The Energy-use dataset employed to calculate energy-related metrics (e.g., g m⁻², g kWh⁻¹) is stored in the data/ directory as Energy.xlsx.

The statistical input tables used for ANOVA, Tukey HSD and PCA are stored alongside the scripts in analysis/python/.

For the final published version of the article, this repository may be supplemented by a frozen snapshot of code and data deposited in an external research repository (e.g., Zenodo, Figshare or OSF) under a citable DOI. The DOI and corresponding Git tag/release will be added to this README once available.

Researchers interested in using the full control software or in accessing additional raw data not directly included here may contact the corresponding author. Reasonable requests for academic, non-commercial use will be evaluated on a case-by-case basis.

7. License and contact

License
To be defined by the authors according to the desired level of openness and potential commercialization (e.g., MIT License for open-source code, or a more restrictive license if preferred). Once chosen, a LICENSE file will be added to this repository.

Corresponding author
Marlus Dias Silva
Goiano Federal Institute of Education, Science and Technology, Rio Verde, Brazil
E-mail: marlus.silva@ifgoiano.edu.br

Please cite the associated article when using this code or data in scientific publications.
