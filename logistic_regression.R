# ==========================================================
# Logistic Regression + Prediction + ROC Curve + 4 Figures
# Outputs: JPG files
# ==========================================================

# Load packages
library(tidyverse)
library(pROC)

# Create output directory
outdir <- "figs"
if (!dir.exists(outdir)) dir.create(outdir, recursive = TRUE)

# ----------------------------------------------------------
# Load cleaned dataset (relative path)
# ----------------------------------------------------------
melb <- readRDS(file.path("derived_data", "melb_cleaned.rds"))

# Ensure all variable names are lowercase
melb <- melb %>% rename_with(tolower)

# ----------------------------------------------------------
# Prepare data for logistic regression
# ----------------------------------------------------------
melb_logit <- melb %>%
  mutate(
    method = tolower(str_trim(method)),
    sold_auction = if_else(method == "s", 1L, 0L),
    log_price = log(price)
  ) %>%
  select(
    sold_auction, log_price, rooms, bathroom, car,
    distance, type
  ) %>%
  drop_na() %>%
  mutate(type = as.factor(type))

print(table(melb_logit$sold_auction))

# ----------------------------------------------------------
# Fit logistic regression
# ----------------------------------------------------------
logit_model <- glm(
  sold_auction ~ log_price + rooms + bathroom + car + distance + type,
  data = melb_logit,
  family = binomial(link = "logit")
)

summary(logit_model)

# Predicted probability
melb_logit$pred_prob <- predict(logit_model, type = "response")

# ==========================================================
# FIGURE 1: Probability vs Distance
# ==========================================================
p_prob_dist <- ggplot(melb_logit,
                      aes(x = distance, y = pred_prob, color = type)) +
  geom_point(alpha = 0.4, size = 1.5) +
  geom_smooth(method = "loess", se = FALSE, linewidth = 1) +
  labs(
    title = "Predicted Probability of Selling at Auction (S)",
    x = "Distance from CBD",
    y = "Predicted Probability",
    color = "Type"
  ) +
  theme_minimal()

ggsave(
  file.path(outdir, "logit_prob_distance.jpg"),
  p_prob_dist, dpi = 500, width = 7, height = 5
)

# ==========================================================
# FIGURE 2: Probability vs log(Price)
# ==========================================================
p_prob_price <- ggplot(melb_logit,
                       aes(x = log_price, y = pred_prob)) +
  geom_point(alpha = 0.4, size = 1.5) +
  geom_smooth(method = "loess", se = FALSE, color = "blue", linewidth = 1) +
  labs(
    title = "Predicted Probability vs log(Price)",
    x = "log(Price)",
    y = "Predicted Probability"
  ) +
  theme_minimal()

ggsave(
  file.path(outdir, "logit_prob_price.jpg"),
  p_prob_price, dpi = 500, width = 7, height = 5
)

# ==========================================================
# FIGURE 3: ROC Curve
# ==========================================================
roc_obj <- roc(
  response = melb_logit$sold_auction,
  predictor = melb_logit$pred_prob
)

roc_df <- tibble(
  tpr = roc_obj$sensitivities,
  fpr = 1 - roc_obj$specificities
)

auc_value <- auc(roc_obj)

p_roc <- ggplot(roc_df, aes(x = fpr, y = tpr)) +
  geom_line(linewidth = 1) +
  geom_abline(linetype = "dashed") +
  annotate(
    "text", x = 0.65, y = 0.1,
    label = paste0("AUC = ", round(auc_value, 3))
  ) +
  labs(
    title = "ROC Curve for Auction-Day Sale Model",
    x = "False Positive Rate",
    y = "True Positive Rate"
  ) +
  theme_minimal()

ggsave(
  file.path(outdir, "logit_roc.jpg"),
  p_roc, dpi = 500, width = 6, height = 6
)

# ==========================================================
# FIGURE 4: Predicted Probability Histogram
# ==========================================================
p_prob_hist <- ggplot(melb_logit,
                      aes(x = pred_prob, fill = factor(sold_auction))) +
  geom_histogram(bins = 30, alpha = 0.7, position = "identity") +
  facet_wrap(~ sold_auction, ncol = 1) +
  labs(
    title = "Distribution of Predicted Probabilities",
    x = "Predicted Probability",
    y = "Count",
    fill = "Sold at Auction (S)"
  ) +
  theme_minimal()

ggsave(
  file.path(outdir, "logit_prob_hist.jpg"),
  p_prob_hist, dpi = 500, width = 7, height = 6
)

# ==========================================================
cat("All logistic regression figures saved to: ", normalizePath(outdir))
# ==========================================================

