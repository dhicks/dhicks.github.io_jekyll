---
style: post
title: RMarkdown test post
output:
    html_document:
        keep_md: true
---



Some text 


```r
1+1
```

```
## [1] 2
```

Other text


```r
set.seed(42)
dataf = tibble(x = rnorm(200, 0, 1), 
               eps = rnorm(200, 0, .1), 
               y = 3 + 2*x + eps)

ggplot(dataf, aes(x, y)) +
    geom_point() +
    geom_smooth()
```

```
## `geom_smooth()` using method = 'loess' and formula 'y ~ x'
```

![]({{site_url}}/img/blog_images/test_files/figure-html/unnamed-chunk-3-1.png)<!-- -->


