#=====================================================================#
# This is code to create: 01.0-scrape-usada.R
# Authored by and feedback to:
# MIT License
# Version:
#=====================================================================#

# create figs folder ----
if (!file.exists("figs/")) {
    dir.create("figs/")
}
# create data folder ----
if (!file.exists("data/")) {
    dir.create("data/")
}
# create docs folder ----
if (!file.exists("docs/")) {
    dir.create("docs/")
}


# packages ----------------------------------------------------------------

library(tidyverse)
library(rvest)
library(methods)
library(magrittr)
library(ggthemes)
library(extrafont)
library(ggplot2)
library(gridExtra)
library(wesanderson)
library(tidytext)



# read_html_USADA  --------------------------------------------------------

USADA_url <- "https://www.usada.org/testing/results/sanctions/"
USADA_extraction <- USADA_url %>%
     read_html() %>%
     html_nodes("table")



# USADA_extraction_str ----------------------------------------------------

# check the structure of the new USADA_extraction object
# USADA_extraction %>% str()



# USADA_extraction_class --------------------------------------------------
# USADA_extraction %>% class()



# UsadaRaw ----------------------------------------------------------------

UsadaRaw <- rvest::html_table(USADA_extraction[[1]])
# UsadaRaw %>% dplyr::glimpse(70)



# raw_data_path -----------------------------------------------------------

# create data path
raw_data_path <- paste0("data/raw/", base::noquote(lubridate::today()))
raw_data_path
# create a new data folder
if (!file.exists(raw_data_path)) {
    dir.create(raw_data_path)
}

# export_raw --------
# export the .csv file
# export the .csv file
write_csv(as.data.frame(UsadaRaw), 
          paste0(raw_data_path, "/",
                 "UsadaRaw-",
                 base::noquote(lubridate::today()),
                 ".csv"))
# export as a .RData file, too.
save.image(file = paste0(raw_data_path, "/",
                         "UsadaRaw-", 
                         base::noquote(lubridate::today()),
                         ".RData"))
# check
# writeLines(fs::dir_ls("data/raw", 
#                       regexp = base::noquote(lubridate::today())))

