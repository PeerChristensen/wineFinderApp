

library(tidyverse)
library(h2o)
library(FNN)

df <- read_csv("winemag-data-130k-v2.csv") %>%
  select(id=X1,title,description,variety,country, province,points,price) %>%
  mutate(description2 = gsub('[[:punct:] ]+',' ',description)) %>%
  mutate(description2 = tolower(description2)) %>%
  distinct(title,.keep_all = T) %>%
  filter(country=="US")

h2o.init()

hf <- as.h2o(df)

words <- h2o.tokenize(hf$description2,split=" ")

#w2v_model <- h2o.word2vec(words, model_id = "wine_model_01")

#h2o.saveModel(w2v_model,"/Users/peerchristensen/Desktop/Projects/wine/models")
w2v_model <- h2o.loadModel("/Users/peerchristensen/Desktop/Projects/wine/models/wine_model_01")
print(h2o.findSynonyms(w2v_model, "tobacco", count = 5))
print(h2o.findSynonyms(w2v_model, "bouquet", count = 5))
print(h2o.findSynonyms(w2v_model, "oak", count = 5))
print(h2o.findSynonyms(w2v_model, "peach", count = 5))

#vecs <- h2o.transform_word2vec(w2v_model, words, aggregate_method = "AVERAGE") %>%
#  as_tibble()
vecs <- vroom::vroom("data/wine_reviews_vectors.csv") %>% select(-id)

#h2o.exportFile(vecs,"/Users/peerchristensen/Desktop/Projects/wine/vectors.csv",force=T)

new_text <- "ripe spice jam"

new <- tibble(text = new_text) %>%
  as.h2o() %>%
  h2o.tokenize(split= " ")

vecs_new <- h2o.transform_word2vec(w2v_model, new, aggregate_method = "AVERAGE") %>%
  as_tibble()

vecs2 <- rbind(vecs,vecs_new)

#row.names(df) <- 1:nrow(df)

ind <- knnx.index(vecs2, vecs2[nrow(vecs2),], k=5) %>% as.vector()

dist <- knnx.dist(vecs2, vecs2[nrow(vecs2),], k=5) %>% as.vector()

df[ind[-1],] %>% view()

