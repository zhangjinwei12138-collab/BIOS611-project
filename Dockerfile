FROM rocker/rstudio

## Install required R packages
RUN R -e "install.packages('tidyverse')"
RUN R -e "install.packages('pROC')"
RUN R -e "install.packages('janitor')"

## For rendering R Markdown reports
RUN R -e 'install.packages("knitr")'
RUN R -e 'install.packages("rmarkdown")'