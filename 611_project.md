---
title: "Readme"
output: html_document
date: "2025-11-30"
---

```{r setup, include=FALSE}
knitr::opts_chunk$set(echo = TRUE)
```
# Analysis of Melbourne Housing Market

## Introduction
The Melbourne Housing Dataset used in this project originates from publicly available weekly real estate transaction results posted on Domain.com.au. The raw data was web-scraped and cleaned, resulting in a structured dataset containing financial information, structural characteristics, geographic attributes, and market dynamics for residential properties across metropolitan Melbourne.

Each row represents a single property sale, making the dataset well suited for analyses such as hedonic pricing, spatial modeling, clustering, PCA, and logistic regression on sale outcomes.

Key variables include:

-Rooms: Number of rooms
-Price: Price in dollars
-Method: S - property sold; SP - property sold prior; PI - property passed in; PN - sold prior not disclosed; SN - sold not disclosed; NB - no bid; VB - vendor bid; W - withdrawn prior to auction; SA - sold after auction; SS - sold after auction price not disclosed. N/A - price or highest bid not available.
-Type: br - bedroom(s); h - house,cottage,villa, semi,terrace; u - unit, duplex; t - townhouse; dev site - development site; o res - other residential.
-SellerG: Real Estate Agent
-Date: Date sold
-Distance: Distance from CBD
-Regionname: General Region (West, North West, North, North east …etc)
-Propertycount: Number of properties that exist in the suburb.
-Bedroom2 : Scraped # of Bedrooms
-Bathroom: Number of Bathrooms
-Car: Number of carspots
-Landsize: Land Size
-BuildingArea: Building Size
-CouncilArea: Governing council for the area

This study aims to explore the structure of property features, uncover natural clusters within the market, and predict auction-day sale outcomes.

## Outcomes of Interest
- **Price** (continuous)
- **Sale on Auction Day**:  
  - `1 = S` (Sold at auction)  
  - `0 = all other sale methods`  

## Three Key Questions

1. **Do property features exhibit low-dimensional structure?**  
   **Approach:** Principal Component Analysis (PCA) to identify major latent dimensions (house size, land size, configuration).

2. **Does the housing market exhibit natural clusters based on structural or spatial features?**  
   **Approach:** K-means clustering (and optional hierarchical clustering) using standardized numeric variables (rooms, bathrooms, land size, distance).

3. **Can we predict whether a property will sell on auction day (S vs non-S)?**  
   **Approach:** Logistic Regression with predictors such as rooms, bathrooms, distance to CBD, log(price), and property type.

---

## Setup Instructions

This repository contains a fully reproducible workflow using **Docker**, **R**, **Makefile**, and **R Markdown** (`report.Rmd`).

### 1. Build the Docker Environment

```bash
docker build . -t melb-proj-env
```
