library(tidyverse)
library(tidytext)

post_folder = '_posts/'
post_files = list.files(post_folder) %>%
    str_c(post_folder, .)

## Load posts ----
dataf = tibble(path = post_files) %>%
    mutate(post_id = row_number()) %>%
    rowwise() %>%
    mutate(raw_text = read_file(path)) %>%
    ungroup()

## Parse and calculate information gain ----
tokens_df = unnest_tokens(dataf, token, raw_text)

baseline = log2(nrow(dataf))

info_df = tokens_df %>%
    count(token, post_id) %>%
    group_by(token) %>%
    arrange(token) %>%
    mutate(p = n / sum(n), 
           H_term = -p*log2(p)) %>%
    summarize(n = sum(n), 
              H = sum(H_term), 
              delta_H = baseline - H,
              ndH = log10(n)*delta_H)

## Select high-information terms and ID them in posts ----
vocab = info_df %>%
    top_n(nrow(dataf), ndH)

tags_df = vocab %>%
    select(-n) %>%
    inner_join(tokens_df, by = 'token') %>%
    count(path, post_id, token) %>%
    group_by(path, post_id) %>%
    summarize(tags = list(token)) %>%
    mutate(tags_str = map_chr(tags, str_c, collapse = ','), 
           tags_str = str_c('tags: [', tags_str, ']'))

## Insert tags into post and write to disk
right_join(dataf, tags_df) %>%
    separate(raw_text, into = c('null', 'header', 'body'), 
             sep = '---', extra = 'merge') %>% 
    mutate(combined = str_c('---', 
                            header, 
                            tags_str, '\n',
                            '---', 
                            body)) %>%
    # pull(combined) %>% {cat(.[[1]])}
    rowwise() %>%
    mutate(written = map2(combined, path, write_lines))
