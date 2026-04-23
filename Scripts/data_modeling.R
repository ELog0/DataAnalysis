library(tidyverse)
library(cluster)

# =========================
# DATA FOR REGRESSION
# =========================

fit_df <- national_obesity %>%
  inner_join(national_no_leisure, by = "year") %>%
  drop_na()

fit_pa150_df <- national_obesity %>%
  inner_join(national_150min, by = "year") %>%
  drop_na()

model_data <- state_wide %>%
  select(obesity, fruit_lt1, veg_lt1, pa_150) %>%
  drop_na()

# =========================
# LINEAR MODELS
# =========================

set.seed(123)

fit_lm <- lm(obesity ~ no_leisure + year, data = fit_df)
fit_pa150_lm <- lm(obesity ~ pa_150 + year, data = fit_pa150_df)
lm_full <- lm(obesity ~ fruit_lt1 + veg_lt1 + pa_150, data = model_data)

summary(fit_lm)
summary(fit_pa150_lm)
summary(lm_full)

# =========================
# DUPLICATE CHECK
# =========================

duplicates <- state_selected %>%
  count(year, state_abbr, indicator) %>%
  filter(n > 1) %>%
  arrange(desc(n))

duplicates

# =========================
# TRAIN / TEST SPLIT
# =========================

n <- nrow(model_data)
train_idx <- sample(seq_len(n), size = 0.8 * n)

train_data <- model_data[train_idx, ]
test_data  <- model_data[-train_idx, ]

lm_train <- lm(obesity ~ fruit_lt1 + veg_lt1 + pa_150, data = train_data)

test_data <- test_data %>%
  mutate(predicted_obesity = predict(lm_train, newdata = test_data))

# =========================
# EVALUATION
# =========================

rmse <- sqrt(mean((test_data$obesity - test_data$predicted_obesity)^2))
mae  <- mean(abs(test_data$obesity - test_data$predicted_obesity))

r2_test <- 1 - sum((test_data$obesity - test_data$predicted_obesity)^2) /
  sum((test_data$obesity - mean(test_data$obesity))^2)

cat("RMSE:", round(rmse, 3), "\n")
cat("MAE:", round(mae, 3), "\n")
cat("Test R²:", round(r2_test, 3), "\n")

# =========================
# K-MEANS CLUSTERING
# =========================

set.seed(123)

kmeans_scaled <- scale(model_data)

kmeans_fit <- kmeans(kmeans_scaled, centers = 3, nstart = 25)

kmeans_results <- model_data %>%
  mutate(cluster = factor(kmeans_fit$cluster))

cluster_profile <- kmeans_results %>%
  group_by(cluster) %>%
  summarize(
    n = n(),
    obesity_mean   = mean(obesity),
    fruit_lt1_mean = mean(fruit_lt1),
    veg_lt1_mean   = mean(veg_lt1),
    pa_150_mean    = mean(pa_150),
    .groups = "drop"
  )

cluster_profile

table(kmeans_results$cluster)

# =========================
# SILHOUETTE + ELBOW
# =========================

sil <- numeric(10)

for (k in 2:10) {
  km <- kmeans(kmeans_scaled, centers = k, nstart = 25)
  ss <- silhouette(km$cluster, dist(kmeans_scaled))
  sil[k] <- mean(ss[, 3])
}

wcss <- numeric(10)

for (k in 1:10) {
  km <- kmeans(kmeans_scaled, centers = k, nstart = 25)
  wcss[k] <- km$tot.withinss
}

sil_obj <- silhouette(kmeans_fit$cluster, dist(kmeans_scaled))

# =========================
# PCA FOR VISUALIZATION
# =========================

pca <- prcomp(kmeans_scaled)

pca_df <- data.frame(
  PC1 = pca$x[, 1],
  PC2 = pca$x[, 2],
  cluster = factor(kmeans_fit$cluster)
)

centroids <- aggregate(
  cbind(PC1, PC2) ~ cluster,
  data = pca_df,
  mean
)