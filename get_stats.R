library(reshape)
library(dplyr)
library(ppcor)
library(ggplot2)
library(plotrix)
library(xtable)
library(hexbin)
library(lme4)
library(sqldf)


z.test = function(a, mu, var){
  zeta = (mean(a) - mu) / var
  return(zeta)
}


p.val = function(z){
  return(2*pnorm(-abs(z)))
}

cor.test.p <- function(x, y) {return(as.numeric(cor.test(x, y, method='pearson')[3]))}
cor.test.lower <- function(x, y) {return(as.numeric(cor.test(x, y, method='pearson')[9]$conf.int[1]))}
cor.test.upper <- function(x, y) {return(as.numeric(cor.test(x, y, method='pearson')[9]$conf.int[2]))}


setwd("/Users/sbll/Dropbox/wiki_freq_simulation/celex/simulated")

a <- list.files()
a <- a[grep('*.txt', a)]
b <- gsub('_1_0_0_40_iter1000_mngram_n5_smoothing0.01\\.txt', '', a)
b <- gsub('sim_out_freq__lemma_', '', b)

d <- NULL
for (i in 1:length(a)) {
  print(a[i])
  f <- file(paste('./', a[i], sep=''))
  df <- sqldf("select * from f", dbname = tempfile(), file.format = list(header = F, row.names = F, sep = ","))
  df[,8] <- b[i]
  d <- rbind(d, df)
}

names(d) <- c("lex","word","count","prob","mps","length","prob_lex","lang")

d <- d[d$length >= 3 & d$length <= 7, ]
d <- group_by(d, lex, lang, length)
d$lc <- log(d$count + 1)

d.sum <- summarise(d, 
                   cor.mp.f = cor(lc, mps, method='pearson'),
                   cor.prob.f = cor(lc, prob_lex, method='pearson'),
                   cor.prob.mp = cor(prob_lex, mps, method='pearson'),
                   cor.mp.f.p = cor.test.p(lc, mps),
                   cor.prob.f.p = cor.test.p(lc, prob_lex),
                   cor.prob.mp.p = cor.test.p(prob_lex, mps),
                   cor.mp.f.lower = cor.test.lower(lc, mps),
                   cor.prob.f.lower = cor.test.lower(lc, prob_lex),
                   cor.mp.f.upper = cor.test.upper(lc, mps),
                   cor.prob.f.upper = cor.test.upper(lc, prob_lex))

write.table(d.sum, "celex_simulated_lex_corr.txt", quote =FALSE, sep=",",row.names = FALSE)






setwd("/Users/sbll/Dropbox/wiki_freq_simulation/celex")

a <- list.files()
a <- a[grep('*.txt', a)]
b <- gsub('_1_0_0_40\\.txt', '', a)
b <- gsub('out_freq__lemma_', '', b)

d <- NULL
for (i in 1:length(a)) {
  print(a[i])
  f <- file(paste('./', a[i], sep=''))
  df <- sqldf("select * from f", dbname = tempfile(), file.format = list(header = T, row.names = F, sep = "\t"))
  df$lang <- b[i]
  d <- rbind(d, df)
}

d <- d[d$length >= 3 & d$length <= 7, ]
d <- group_by(d, lang, length)
d$lc <- log(d$count + 1)

d.sum <- summarise(d, 
                   cor.mp.f = cor(lc, mps, method='pearson'),
                   cor.prob.f = cor(lc, prob, method='pearson'),
                   cor.prob.mp = cor(prob, mps, method='pearson'),
                   cor.mp.f.p = cor.test.p(lc, mps),
                   cor.prob.f.p = cor.test.p(lc, prob),
                   cor.prob.mp.p = cor.test.p(prob, mps),
                   cor.mp.f.lower = cor.test.lower(lc, mps),
                   cor.prob.f.lower = cor.test.lower(lc, prob),
                   cor.mp.f.upper = cor.test.upper(lc, mps),
                   cor.prob.f.upper = cor.test.upper(lc, prob))

write.table(d.sum, "celex_real_lex_corr.txt", quote =FALSE, sep=",",row.names = FALSE)



setwd("/Users/sbll/Dropbox/wiki_freq_simulation/wiki")

a <- list.files()
a <- a[grep('*.txt', a)]
b <- gsub('\\.txt', '', a)
b <- gsub('out_', '', b)

d <- NULL
for (i in 1:length(a)) {
  print(a[i])
  f <- file(paste('./', a[i], sep=''))
  df <- sqldf("select * from f", dbname = tempfile(), file.format = list(header = T, row.names = F, sep = "\t"))
  df$lang <- b[i]
  d <- rbind(d, df)
}

d <- d[d$length >= 3 & d$length <= 7, ]
d <- group_by(d, lang, length)
d$lc <- log(d$count + 1)

d.sum <- summarise(d, 
                   cor.mp.f = cor(lc, mps, method='pearson'),
                   cor.prob.f = cor(lc, prob, method='pearson'),
                   cor.prob.mp = cor(prob, mps, method='pearson'),
                   cor.mp.f.p = cor.test.p(lc, mps),
                   cor.prob.f.p = cor.test.p(lc, prob),
                   cor.prob.mp.p = cor.test.p(prob, mps),
                   cor.mp.f.lower = cor.test.lower(lc, mps),
                   cor.prob.f.lower = cor.test.lower(lc, prob),
                   cor.mp.f.upper = cor.test.upper(lc, mps),
                   cor.prob.f.upper = cor.test.upper(lc, prob))

write.table(d.sum, "wiki_real_lex_corr.txt", quote =FALSE, sep=",",row.names = FALSE)



d.sim <- read.table("/Users/sbll/Dropbox/wiki_freq_simulation/celex/celex_sim_only/celex_simulated_lex_corr.txt", sep=",",header=TRUE)
d.real <- read.table("/Users/sbll/Dropbox/wiki_freq_simulation/celex/celex_real/celex_real_lex_corr.txt", sep=",",header=TRUE)




d.sim <- read.table("/Users/sbll/Dropbox/wiki_freq_simulation/wiki_corr_all.txt", sep=",",header=TRUE)
d.real <- read.table("/Users/sbll/Dropbox/wiki_freq_simulation/wiki_real_lex_corr.txt", sep=",",header=TRUE)


d.sim <- group_by(d.sim, lang, length)
d.sim.stats <- summarize(d.sim,
                         mu.mp.f = mean(cor.mp.f,na.rm=TRUE),
                         mu.prob.f = mean(cor.prob.f,na.rm=TRUE),
                         mu.prob.mp = mean(cor.prob.mp,na.rm=TRUE),
                         var.mp.f = sd(cor.mp.f,na.rm=TRUE),
                         var.prob.f = sd(cor.prob.f,na.rm=TRUE),
                         var.prob.mp = sd(cor.prob.mp,na.rm=TRUE))

d.stats <- merge(d.real, d.sim.stats)
d.stats <- group_by(d.stats, lang, length)
d.stats <- mutate(d.stats,
                         z.mp.f = z.test(cor.mp.f, mu.mp.f, var.mp.f),
                         z.prob.f = z.test(cor.prob.f, mu.prob.f, var.prob.f),
                         z.prob.mp = z.test(cor.prob.mp, mu.prob.mp, var.prob.mp),
                         p.mp.f = p.val(z.mp.f),
                         p.prob.f = p.val(z.prob.f),
                         p.prob.mp = p.val(z.prob.mp),
                         sig.mp.f = ifelse(p.mp.f>0.01, 'n.s', '*'),
                         sig.prob.f = ifelse(p.prob.f>0.01, 'n.s', '*'),
                         sig.prob.mp = ifelse(p.prob.mp>0.01, 'n.s', '*'),
                  )

write.table(d.stats, "wiki_results.txt", quote =FALSE, sep=",",row.names = FALSE)


