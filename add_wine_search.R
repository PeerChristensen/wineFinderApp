# search on wine-searcher
library(tidyverse)

text <- "The Four Graces 2007 Pinot Gris (Dundee Hills)"
text <- gsub(" ","+",text)
text <- gsub("\\(|\\)","",text)
text <- tolower(text)
the+four+graces+2007+pinot+gris+dundee+hills/
  
url <- paste0("https://www.wine-searcher.com/find/",text)

link <- glue::glue("<a href={url}>Find it!</a>")
# https://www.wine-searcher.com/find/the+four+grace+pinot+gris+dundee+hill+willamette+valley+oregon+usa/2007/denmark/-

  
  ###
  
df <- read_csv("data/wine_reviews.csv") 

df <- df %>%
  mutate(link = str_replace_all(title," ","+")) %>%
  mutate(link = str_replace_all(link,"\\(|\\)","")) %>%
  mutate(link = paste0("https://www.wine-searcher.com/find/",link)) %>%
  mutate(link = glue::glue('<a href={link} target="_blank">Find it!</a>'))

write_csv(df,"data/wine_reviews.csv")
