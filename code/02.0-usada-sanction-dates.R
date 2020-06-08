#=====================================================================#
# This is code to create: 02.0-usada-sanction-dates.R
# Authored by and feedback to:
# MIT License
# Version: 1.0
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

library(knitr)
library(rmdformats)
library(tidyverse)
library(devtools)
library(hrbrthemes)


# base options
base::options(
  tibble.print_max = 25,
  tibble.width = 78,
   max.print = 999999,
  scipen = 100000000
)


## ---- 01-scrape-usada.R --------
source("code/01.0-scrape-usada.R")


## ----here-package -----------------------------------
## library(here)
## library(fs)


## ----dr_here ----------------------------------------
## here::dr_here()


## ----data-tree------------------------------------------------------------------
recent_raw_data_file_path <- fs::dir_info("data/raw") %>% 
  dplyr::select(path, birth_time) %>% 
  dplyr::arrange(desc(birth_time)) %>% 
  dplyr::slice(1) %>% 
  dplyr::select(path) %>% 
  as_vector()


## ----today----------------------------------------------------------------------
today <- lubridate::today()



## ----raw_data_csv_path----------------------------------------------------------
raw_data_csv_path <- here::here(recent_raw_data_file_path, 
                                base::paste0("UsadaRaw-", today,".csv"))


## ----import-raw_file_path-------------------------------------------------------
UsadaRaw <- readr::read_csv(file = raw_data_csv_path)


## ----clean-names ----------------------------------
library(janitor)
Usada <- UsadaRaw %>% 
    janitor::clean_names(dat = ., 
                         case = "snake")
# Usada %>% glimpse(78)


## ----map_df---------------------------------------------------------------------
# lowercase text -----
Usada <- purrr::map_df(.x = Usada, .f = stringr::str_to_lower)



## ----UsadaNoNames---------------------------------------------------------------
# create no name sanctions
UsadaNoNames <- Usada %>% 
    dplyr::filter(athlete == "*name removed")
# create named sanctions
UsadaNames <- Usada %>% 
    dplyr::filter(athlete != "*name removed")
# UsadaNoNames %>% dplyr::glimpse(78)
# UsadaNames %>% dplyr::glimpse(78)


## ----sanction_date--------------------------------------------------------------
# format sanction announced date ------
# test
UsadaNames %>% 
    dplyr::mutate(sanction_date = lubridate::mdy(sanction_announced))

# Warning message:
#   22 failed to parse.
## ----arrange-sanctions----------------------------------------------------------
UsadaNames %>%
    # order by sanction_announced
        dplyr::arrange(desc(sanction_announced)) %>% 
    # reorganize columns
        dplyr::select(athlete, 
                  sanction_announced,
                  dplyr::everything())


## ----UsadaBadDates--------------------------------------------------------------
UsadaBadDates <- UsadaNames %>%
    dplyr::filter(stringr::str_detect(string = sanction_announced,
                                      pattern = "original")) %>% 
    dplyr::select(athlete, 
                  sanction_announced,
                  dplyr::everything())


## ----clean-bad-dates ------------------------------
UsadaFixedDates <- UsadaBadDates %>%
        dplyr::mutate(sanction_dates = 
    # 1) split this on the "updated" pattern
             stringr::str_split(string = sanction_announced, 
                                pattern = "updated")) %>% 
    # 2) convert the output from split into multiple rows
        tidyr::unnest(sanction_dates) %>%  
    # 3) remove the "original" dates 
        dplyr::filter(!str_detect(string = sanction_dates, 
                                  pattern = "original")) %>% 
    # 4) remove the colon from sanction_dates
        dplyr::mutate(sanction_dates = stringr::str_remove_all(
                                                      string = sanction_dates,
                                                      pattern = ":"),
                      # 5) remove any whitespace
                      sanction_dates = stringr::str_trim(sanction_dates),
                      # 6) format as date
                      sanction_dates = lubridate::mdy(sanction_dates)) %>% 
    # 7) reorganize the variables 
        dplyr::select(athlete,
                      sport,
                      sanction_terms,
                      substance_reason,
                      dplyr::everything())


## ----UsadaNamesGoodDates--------------------------------------------------------
# remove bad dates from original data 
UsadaNamesGoodDates <- UsadaNames %>% 
    dplyr::filter(!stringr::str_detect(string = sanction_announced,
                                      pattern = "original"))
# bind these together 
UsadaSanctions <- UsadaFixedDates %>% 
    dplyr::bind_rows(., UsadaNamesGoodDates, 
                     .id = "group")

# UsadaSanctions %>% dplyr::glimpse(78)


## ----export-wrangle  --------------------------------------------------
# create data folder ----
if (!file.exists("data/processed")) {
    dir.create("data/processed")
}

# export UsadaSanctions
readr::write_csv(as.data.frame(UsadaSanctions), 
                 path = base::paste0("data/processed/", 
                           base::noquote(lubridate::today()),
                           "-02.0-UsadaSanctions.csv"))
# export UsadaSanctions
readr::write_csv(as.data.frame(UsadaSanctions), 
                 path = base::paste0("data/processed/", 
                           base::noquote(lubridate::today()),
                           "-02.0-UsadaNoNames.csv"))

# export the entire image
base::save.image(file = paste0("data/processed/",
                               base::noquote(lubridate::today()), 
                               "-02.0-usada-sanction-dates.RData"))

fs::dir_tree("data/processed", 
             regexp = base::noquote(lubridate::today()))

