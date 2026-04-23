# Health Data Analysis: Obesity, Nutrition, and Physical Activity

## Overview

This project analyzes national and state-level health data to understand relationships between **obesity rates**, **diet (fruit/vegetable intake)**, and **physical activity**.

The analysis includes data cleaning, feature engineering, statistical modeling, and clustering to identify patterns and key drivers of obesity across the United States.

---

## Key Questions

* How does physical activity relate to obesity rates?
* Is low fruit/vegetable consumption associated with higher obesity?
* Can states be grouped into clusters based on health behaviors?

---

## Key Findings

* Higher levels of **physical inactivity** are positively associated with higher obesity rates.
* States with **lower fruit and vegetable consumption** tend to have higher obesity prevalence.
* Clustering reveals distinct groups of states with similar health behavior patterns (e.g., high inactivity + high obesity).

---

## Methods

### Data Processing

* Filtered national and state-level health data
* Created standardized indicators:

  * `obesity`
  * `overweight`
  * `fruit_lt1` (low fruit consumption)
  * `veg_lt1` (low vegetable consumption)
  * `pa_150` (meets physical activity guidelines)

### Statistical Modeling

* Linear regression models:

  * Obesity vs physical inactivity
  * Obesity vs physical activity (≥150 min/week)
  * Multivariate regression using diet + activity variables
* Train/test split with evaluation metrics:

  * RMSE
  * MAE
  * R²

### Clustering

* K-means clustering on health indicators
* Scaled variables for fair comparison
* Evaluated cluster quality using:

  * Elbow method
  * Silhouette scores

### Dimensionality Reduction

* PCA used to visualize clusters in 2D space

---

## Visualizations

The project includes:

* Time-series trends (obesity vs overweight)
* Boxplots of health indicators across states
* Regression plots (obesity vs activity/diet)
* Cluster visualizations (PCA projection)

---

## Project Structure

```bash
scripts/
  data_processing.R     # data cleaning + feature engineering
  modeling.R            # regression, clustering, evaluation
  visualization.R       # plots

data/
  raw/                  # original dataset (not tracked)
  processed/            # cleaned data (optional)

results/
  figures/              # saved plots
```

---

## How to Run

```r
source("scripts/data_processing.R")
source("scripts/modeling.R")
source("scripts/visualization.R")
```

---

## Dataset

Due to file size limitations, the dataset is not included in this repository.

Download the dataset and place it in:

```
data/raw/cleaned_nutrition_data.csv
```

---

## Skills Demonstrated

* Data cleaning and transformation (R, tidyverse)
* Statistical modeling and evaluation
* Machine learning (k-means clustering)
* Data visualization (ggplot2)
* Feature engineering and pipeline structuring

---

## Future Improvements

* Add additional predictors (income, education, demographics)
* Try more advanced models (random forest, regression regularization)
* Build an interactive dashboard (Shiny or web app)



[Your Name]
