# ================================
# Makefile for Melbourne Housing Project
# ================================

# Clean all generated files
clean:
	rm -f derived_data/*.rds
	rm -f derived_data/*.csv
	rm -f figs/*.jpg
	rm -f report.html

# --------------------------------
# Build cleaned dataset
# --------------------------------
derived_data/melb_cleaned.rds: clean_data.R source_data/melb_data.csv
	Rscript clean_data.R

# --------------------------------
# Logistic Regression Figures
# --------------------------------
figs/logit_prob_distance.jpg: derived_data/melb_cleaned.rds logistic_regression.R
	Rscript logistic_regression.R

figs/logit_prob_price.jpg: derived_data/melb_cleaned.rds logistic_regression.R
	Rscript logistic_regression.R

figs/logit_roc.jpg: derived_data/melb_cleaned.rds logistic_regression.R
	Rscript logistic_regression.R

figs/logit_prob_hist.jpg: derived_data/melb_cleaned.rds logistic_regression.R
	Rscript logistic_regression.R

# --------------------------------
# PCA + Clustering Figures
# --------------------------------
figs/pca_by_type.jpg: derived_data/melb_cleaned.rds pca_analysis.R
	Rscript pca_analysis.R

figs/pca_by_cluster.jpg: derived_data/melb_cleaned.rds pca_analysis.R
	Rscript pca_analysis.R

figs/pca_cumulative_variance.jpg: derived_data/melb_cleaned.rds pca_analysis.R
	Rscript pca_analysis.R

figs/pca5_cluster.jpg: derived_data/melb_cleaned.rds pca_analysis.R
	Rscript pca_analysis.R

# --------------------------------
# Final Report
# --------------------------------
report.pdf: report.Rmd figs/logit_prob_distance.jpg figs/logit_prob_price.jpg figs/logit_roc.jpg figs/logit_prob_hist.jpg figs/pca_by_type.jpg figs/pca_by_cluster.jpg figs/pca_cumulative_variance.jpg figs/pca5_cluster.jpg
	Rscript -e "rmarkdown::render('report.Rmd', output_format='html_document')"

