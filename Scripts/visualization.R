library(tidyverse)
library(ggrepel)
library(factoextra)

# =========================
# NATIONAL TREND PLOTS
# =========================

ggplot(combined, aes(x = year, y = percent, color = category)) +
  geom_line(linewidth = 1.3) +
  geom_point(size = 2) +
  labs(
    title = "National Obesity vs Overweight Trends",
    x = "Year",
    y = "Percent"
  ) +
  theme_minimal()

ggplot(national_no_leisure, aes(x = year, y = no_leisure)) +
  geom_line() +
  geom_point(size = 2) +
  geom_smooth(method = "lm", se = FALSE) +
  labs(
    title = "Trend in No Leisure-Time Physical Activity",
    x = "Year",
    y = "Percent"
  ) +
  theme_minimal()

# =========================
# STATE DISTRIBUTION PLOT
# =========================

ggplot(state_selected, aes(x = indicator, y = percent)) +
  geom_boxplot(outlier.alpha = 0.4) +
  coord_flip() +
  labs(
    title = "Distribution of Health Indicators Across States",
    x = "Indicator",
    y = "Percent"
  ) +
  theme_minimal()

# =========================
# REGRESSION VISUALS
# =========================

ggplot(fit_df, aes(x = no_leisure, y = obesity, label = year)) +
  geom_point(size = 2) +
  ggrepel::geom_text_repel(size = 3) +
  geom_smooth(method = "lm", se = FALSE) +
  labs(
    title = "Obesity vs No Leisure Activity",
    x = "No Leisure Activity (%)",
    y = "Obesity (%)"
  ) +
  theme_minimal()

ggplot(fit_pa150_df, aes(x = pa_150, y = obesity, label = year)) +
  geom_point(size = 2) +
  ggrepel::geom_text_repel(size = 3) +
  geom_smooth(method = "lm", se = FALSE) +
  labs(
    title = "Obesity vs Physical Activity (≥150 min/week)",
    x = "Meets PA ≥150 (%)",
    y = "Obesity (%)"
  ) +
  theme_minimal()

ggplot(test_data, aes(x = obesity, y = predicted_obesity)) +
  geom_point(size = 2) +
  geom_abline(slope = 1, intercept = 0, linetype = "dashed", color = "blue") +
  labs(
    title = "Predicted vs Actual Obesity",
    x = "Observed Obesity (%)",
    y = "Predicted Obesity (%)"
  ) +
  theme_minimal()

ggplot(lm_train, aes(.fitted, .resid)) +
  geom_point(alpha = 0.6) +
  geom_hline(yintercept = 0, linetype = "dashed") +
  labs(
    title = "Residuals vs Fitted",
    x = "Fitted Values",
    y = "Residuals"
  ) +
  theme_minimal()

# =========================
# CLUSTERING VISUALS
# =========================

plot(
  2:10, sil[2:10],
  type = "b", pch = 19,
  xlab = "Number of Clusters (k)",
  ylab = "Average Silhouette Score",
  main = "Silhouette Method"
)

plot(
  1:10, wcss[1:10],
  type = "b", pch = 19,
  xlab = "k",
  ylab = "Total Within-Cluster SS",
  main = "Elbow Method (WCSS)"
)

ggplot(pca_df, aes(x = PC1, y = PC2, color = cluster)) +
  geom_point(size = 2, alpha = 0.7) +
  geom_point(
    data = centroids,
    aes(x = PC1, y = PC2),
    size = 5,
    shape = 4,
    stroke = 2,
    color = "black"
  ) +
  labs(
    title = "K-means Clusters (PCA Projection)",
    x = "Principal Component 1",
    y = "Principal Component 2",
    color = "Cluster"
  ) +
  theme_minimal()

ggplot(kmeans_results, aes(x = fruit_lt1, y = obesity, color = cluster)) +
  geom_point() +
  labs(
    title = "Clusters by Fruit Consumption and Obesity",
    x = "Fruit < 1 Time Daily (%)",
    y = "Obesity (%)"
  ) +
  theme_minimal()

fviz_silhouette(sil_obj)