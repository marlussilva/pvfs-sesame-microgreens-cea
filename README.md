# An Open-Architecture Precision Vertical Farming System for Sesame Microgreens: Audit-Ready Telemetry for Dynamic Lighting and Energy--Biomass Benchmarking

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Python](https://img.shields.io/badge/python-3.8%2B-blue)](https://www.python.org/)
[![Dart](https://img.shields.io/badge/dart-3.0%2B-0175C2)](https://dart.dev/)
[![Flutter](https://img.shields.io/badge/flutter-3.0%2B-02569B)](https://flutter.dev/)

This repository provides the **source code** and **analysis scripts** supporting the manuscript:

> **An Open-Architecture Precision Vertical Farming System for Sesame Microgreens: Audit-Ready Telemetry for Dynamic Lighting and Energy--Biomass Benchmarking**
>
> *Marlus Dias Silva, Jaqueline Martins Vasconcelos, Fábia Barbosa da Silva, Adriano Soares de Oliveira Bailão, Ítalo Moraes Rocha Guedes, Márcio da Silva Vilela, Adriano Carvalho Costa, Márcio Rosa, Lucas Loram Lourenço, Fabiano Guimarães Silva.*
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


