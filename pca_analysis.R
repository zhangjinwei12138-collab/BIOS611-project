# ==========================================================
# PCA + K-means Clustering + 4 Figures
# Outputs: JPG files + PCA results
# ==========================================================

library(tidyverse)

# -----------------------------
# Directories (relative paths)
# -----------------------------
outdir       <- "figs"
derived_dir  <- "derived_data"

if (!dir.exists(outdir))      dir.create(outdir, recursive = TRUE)
if (!dir.exists(derived_dir)) dir.create(derived_dir, recursive = TRUE)

# -----------------------------
# Load cleaned dataset
# -----------------------------
melb <- readRDS(file.path(derived_dir, "melb_cleaned.rds")) %>%
  rename_with(tolower)

# -----------------------------
# Select numeric variables for PCA
# -----------------------------
num_vars <- melb %>%
  select(
    price, rooms, bathroom, car, distance,
    landsize, building_area, propertycount, bedroom2
  ) %>%
  drop_na()

# Keep matching property type for plotting
type_vec <- melb$type[as.numeric(rownames(num_vars))]

# -----------------------------
# PCA
# -----------------------------
pca_obj    <- prcomp(num_vars, center = TRUE, scale. = TRUE)
pca_scores <- as.data.frame(pca_obj$x)

# Extract PC1 and PC2
pca_df <- pca_scores %>%
  transmute(pc1 = PC1, pc2 = PC2) %>%
  mutate(type = type_vec)

# -----------------------------
# K-means on 2 PCs
# -----------------------------
set.seed(42)
k_val <- 3
km2   <- kmeans(pca_df[, c("pc1", "pc2")], centers = k_val, nstart = 20)
pca_df$cluster <- factor(km2$cluster)

# -----------------------------
# FIGURE 1: PCA colored by property type
# -----------------------------
p_pca_type <- ggplot(pca_df, aes(pc1, pc2, color = type)) +
  geom_point(alpha = 0.6, size = 1.8) +
  labs(
    title = "PCA: PC1 vs PC2 by Property Type",
    x = "PC1", y = "PC2"
  ) +
  theme_minimal()

ggsave(
  file.path(outdir, "pca_by_type.jpg"),
  p_pca_type, dpi = 500, width = 7, height = 5
)

# -----------------------------
# FIGURE 2: PCA colored by K-means clusters
# -----------------------------
p_pca_cluster <- ggplot(pca_df, aes(pc1, pc2, color = cluster)) +
  geom_point(alpha = 0.7, size = 1.8) +
  labs(
    title = paste("K-means Clustering (k =", k_val, ") on PC1 and PC2"),
    x = "PC1", y = "PC2", color = "Cluster"
  ) +
  theme_minimal()

ggsave(
  file.path(outdir, "pca_by_cluster.jpg"),
  p_pca_cluster, dpi = 500, width = 7, height = 5
)

# -----------------------------
# FIGURE 3: Cumulative variance explained
# -----------------------------
pca_var  <- pca_obj$sdev^2
pca_prop <- pca_var / sum(pca_var)
pca_cum  <- cumsum(pca_prop)

cum_df <- tibble(
  pc      = seq_along(pca_cum),
  cum_var = pca_cum
)

p_cum <- ggplot(cum_df, aes(pc, cum_var)) +
  geom_point(size = 3) +
  geom_line(linewidth = 1) +
  scale_x_continuous(breaks = cum_df$pc) +
  scale_y_continuous(breaks = seq(0, 1, 0.1), limits = c(0, 1)) +
  geom_hline(yintercept = 0.8, linetype = "dashed") +
  labs(
    title = "Cumulative Variance Explained by PCs",
    x = "Number of PCs",
    y = "Cumulative Proportion"
  ) +
  theme_minimal()

ggsave(
  file.path(outdir, "pca_cumulative_variance.jpg"),
  p_cum, dpi = 500, width = 7, height = 5
)

# -----------------------------
# FIGURE 4: K-means on top 5 PCs (PC1 vs PC2 colored by cluster)
# -----------------------------
pc5 <- pca_scores[, 1:5]

set.seed(42)
km5 <- kmeans(pc5, centers = k_val, nstart = 20)

pc5_plot <- as_tibble(pc5) %>%
  mutate(cluster = factor(km5$cluster))

p_pca_pc12 <- ggplot(pc5_plot, aes(PC1, PC2, color = cluster)) +
  geom_point(alpha = 0.7, size = 1.8) +
  labs(
    title = paste("K-means (k =", k_val, ") using Top 5 PCs"),
    x = "PC1", y = "PC2"
  ) +
  theme_minimal()

ggsave(
  file.path(outdir, "pca5_cluster.jpg"),
  p_pca_pc12, dpi = 500, width = 7, height = 5
)

# -----------------------------
# Save PCA results
# -----------------------------
saveRDS(pca_obj, file.path(derived_dir, "pca_model.rds"))
saveRDS(pca_df,  file.path(derived_dir, "pca_data_pc12.rds"))
write.csv(
  pc5_plot,
  file.path(derived_dir, "pca5_kmeans_clusters.csv"),
  row.names = FALSE
)

cat("Done. 4 figures saved to:", normalizePath(outdir), "\n")
