library(dplyr)
library(ggplot2)
library(plotrix)
library(xtable)
library(hexbin)
library(tidyr)
library(readr)
library(ppcor)
library(lars)
library(MASS)


######## Useful fonctions
multiplot <- function(..., plotlist=NULL, file, cols=1, layout=NULL) {
  require(grid)
  
  # Make a list from the ... arguments and plotlist
  plots <- c(list(...), plotlist)
  
  numPlots = length(plots)
  
  # If layout is NULL, then use 'cols' to determine layout
  if (is.null(layout)) {
    # Make the panel
    # ncol: Number of columns of plots
    # nrow: Number of rows needed, calculated from # of cols
    layout <- matrix(seq(1, cols * ceiling(numPlots/cols)),
                     ncol = cols, nrow = ceiling(numPlots/cols))
  }
  
  if (numPlots==1) {
    print(plots[[1]])
    
  } else {
    # Set up the page
    grid.newpage()
    pushViewport(viewport(layout = grid.layout(nrow(layout), ncol(layout))))
    
    # Make each plot, in the correct location
    for (i in 1:numPlots) {
      # Get the i,j matrix positions of the regions that contain this subplot
      matchidx <- as.data.frame(which(layout == i, arr.ind = TRUE))
      
      print(plots[[i]], vp = viewport(layout.pos.row = matchidx$row,
                                      layout.pos.col = matchidx$col))
    }
  }
}


cor.test.p <- function(x, y) {return(as.numeric(cor.test(x, y, method='pearson')[3]))}
cor.test.lower <- function(x, y) {return(as.numeric(cor.test(x, y, method='pearson')[9]$conf.int[1]))}
cor.test.upper <- function(x, y) {return(as.numeric(cor.test(x, y, method='pearson')[9]$conf.int[2]))}
pcor.test.est <- function(x, y, z) {return(pcor.test(x, y, z, method='pearson')$estimate)}
pcor.test.p <- function(x, y, z) {return(pcor.test(x, y, z, method='pearson')$p.value)}

gg_color_hue <- function(n) {
  hues = seq(15, 375, length=n+1)
  hcl(h=hues, l=65, c=100)[1:n]
}

####### Wiki corpora results
d <- read.csv("/Users/sbll/Dropbox/wiki_freq_simulation/wiki/wiki_results.txt")
fams <- read.csv('/Users/sbll/Dropbox/wiki_freq_simulation/languages_studied_updated.csv')
fams$lang = fams$code
fams$lang <- as.character(fams$lang)
d <- merge(d, fams, by = c('lang'))


d$Language_Group = as.character(d$family)
nonindo = filter(d, Indo != "Indo-European", length %in% c(4, 5, 6))
indo = filter(d, Indo == "Indo-European", length %in% c(4, 5, 6))


make.plot <- function(x, y='cor.mp.f', sig = 'sig.mp.f', ggt) {
  x <- (arrange(x, tolower(Language_Group), cor.mp.f))
  x$row <- 1:nrow(x)
  langnum = length(unique(x$lan))
  set.seed(10)
  palette.custom = sample(gg_color_hue(langnum), langnum)
  x$wikilang <- reorder(x$wikilang, -x$row)
  x$keyval <- sprintf("%.2f", round(x[, y], 2))
  x$sigval <- unlist(x[, sig])
  p <- ggplot(x, aes_string(x=y, y='wikilang', colour='Language_Group')) + geom_point(size=3) +
    geom_segment(data=x, aes_string(x=paste(y, '.lower', sep=''), xend=paste(y, '.upper', sep=''), y='wikilang', yend='wikilang'), size=1) + 
    facet_grid(. ~ length) + theme_bw(20) + xlim(-.5, .5) + geom_vline(xintercept=0, alpha=.5, lty=2) + 
    theme(axis.text.x = element_text(size=8)) + geom_text(size=5, aes(x=-.4, label=keyval   )) + geom_text(size=5, aes(x=0.45, label=sigval   )) + 
    xlab('Pearson correlations with 95% CIs') + ylab('language') + 
    scale_colour_manual(values=palette.custom) + ggtitle(ggt)
  print(p)
  return(p)
}


make.plot(nonindo, 'cor.mp.f', 'sig.mp.f', ggt='Non-IE correlations between minimal pairs and frequency')
ggsave('nonie-mp-freq_new.pdf', width=10, height=14)

make.plot(indo, 'cor.mp.f', 'sig.mp.f', ggt="IE correlations between minimal pairs and frequency")
ggsave('ie-mp-freq_new.pdf', width=12, height=16)

make.plot(nonindo, 'cor.prob.f', 'sig.prob.f',ggt='Non-IE correlations between prob. and frequency')
ggsave('nonie-prob-freq_new.pdf', width=10, height=14)

make.plot(indo, 'cor.prob.f', 'sig.prob.f', ggt="IE correlations between prob. and frequency")
ggsave('ie-prob-freq_new.pdf', width=12, height=16)



##in paper 22/06/18
pcor.sum.sum <- group_by(d, length)
summarise(pcor.sum.sum, m=mean(cor.mp.f))
summarise(pcor.sum.sum, m=mean(cor.mp.f > 0))
summarise(pcor.sum.sum, m=mean(p.mp.f < .01 & cor.mp.f > 0))
summarise(pcor.sum.sum, m=mean(cor.prob.f))
summarise(pcor.sum.sum, m=mean(cor.prob.f > 0 ))
summarise(pcor.sum.sum, m=mean(p.prob.f < .01))


d.cel <- read.csv("/Users/sbll/Dropbox/wiki_freq_simulation/celex/celex_results.txt")

make.plot.cel <- function(x, y='cor.mp.f', sig='sig.mp.f', ggt) {
  x$keyval <- sprintf("%.2f", round(unlist(x[, y]), 2))
  x$sigval <- unlist(x[, sig])
  
  p <- ggplot(x, aes_string(x=y, y='lang', colour='lang')) + 
    geom_point(size=3) +
    geom_segment(data=x, aes_string(x=paste(y, '.lower', sep=''), xend=paste(y, '.upper', sep=''), y='lang', yend='lang'), size=1) + 
    facet_grid(. ~ length) + 
    theme_bw(20) + 
    xlim(-.5, .5) + 
    geom_vline(xintercept=0, alpha=.5, lty=2) +
    theme(axis.text.x = element_text(size=10)) + 
    geom_text(size=5, aes(x=-.4, label=keyval   )) + 
    geom_text(size=5, aes(x=0.45, label=sigval   )) + 
    
    xlab('Pearson correlations with 95% CIs') + ylab('language')  +
    ggtitle(ggt)+theme(legend.position = "none")
  print(p)
  return(p)
}

#FIGURE 3
p1 <- make.plot.cel(subset(d.cel, length > 3 & length <7), 'cor.prob.f', 'sig.prob.f',ggt="Correlations between phon. probability and frequency")
p2 <- make.plot.cel(subset(d.cel, length > 3 & length <7), 'cor.mp.f', 'sig.mp.f',ggt="Correlations between minimal pairs and frequency")
pdf('celex_combo.pdf', width=10, height=7)
multiplot(p1, p2)
dev.off()

#FIGURE 4
d <- read.csv('/Users/sbll/Dropbox/wiki/all_lexicon_subtlex_excluded.csv')
d <- d[d$length > 2 & d$length < 8, ]
d <- group_by(d, lang, length)
d$lc <- log(d$count)
ok <- c('en', 'fr', 'nl', 'de')
d <- d[d$lang %in% ok == T, ]
d.sum <- summarise(d, 
                   cor.n.f = cor(lc, neighbors, method='pearson'),
                   cor.mp.f = cor(lc, mps, method='pearson'),
                   cor.prob.f = cor(lc, prob, method='pearson'),
                   cor.prob.n = cor(prob, neighbors, method='pearson'),
                   cor.prob.mp = cor(prob, mps, method='pearson'),
                   cor.n.f.p = cor.test.p(lc, neighbors),
                   cor.mp.f.p = cor.test.p(lc, mps),
                   cor.prob.f.p = cor.test.p(lc, prob),
                   cor.prob.n.p = cor.test.p(prob, neighbors),
                   cor.prob.mp.p = cor.test.p(prob, mps),
                   cor.mp.f.lower = cor.test.lower(lc, mps),
                   cor.prob.f.lower = cor.test.lower(lc, prob),
                   cor.mp.f.upper = cor.test.upper(lc, mps),
                   cor.prob.f.upper = cor.test.upper(lc, prob))

wikilang <- read.csv('/Users/sbll/Dropbox/wiki/wikilang.csv')
d.sum <- merge(d.sum, wikilang, by = c('lang'), all.x=T)
d.sum$lang <- d.sum$wikilang 
d.sum$corpus <- "wiki"
d.cel$corpus <- "celex"
common_cols <- intersect(colnames(d.sum), colnames(d.cel))
d.cel.sum <- rbind(subset(d.sum, select= common_cols), subset(d.cel, select= common_cols))
d.cel.sum <- merge(d.sum, d.cel, by = c('lang', 'length'))
d.cel.sum <- group_by(d.cel.sum, lang)
d.cel.sum.sum <- summarise(d.cel.sum, 
							cor.mp.f.wiki.mean = mean(cor.mp.f.x), 
							cor.mp.f.cel.mean = mean(cor.mp.f.y),
							cor.prob.f.wiki.mean = mean(cor.prob.f.x),
							cor.prob.f.cel.mean = mean(cor.prob.f.y))

ggplot(d.cel.sum.sum, aes(x= cor.mp.f.wiki.mean, y= cor.mp.f.cel.mean, label=lang, color = lang)) + geom_text(hjust=-0.2) +geom_point()  + theme_bw(12)  + ylim(0, .3) + xlim(0, .3) + xlab('Orthographic lexicons correlation value') + ylab('Monomorphemic lexicons correlation value') +theme(legend.position = "none")+ggtitle("Correlations between minimal pairs and frequency")+ geom_abline(intercept = 0, slope =1, alpha=.4)
ggsave('~/wiki_celex_mp_f.pdf', width=5.5, height=5.5)

ggplot(d.cel.sum.sum, aes(x= cor.prob.f.wiki.mean, y= cor.prob.f.cel.mean, label=lang, color = lang)) + geom_text(hjust=-0.2) +geom_point()  + theme_bw(12)  + ylim(0, .35) + xlim(0, .35) + xlab('Orthographic lexicons correlation value') + ylab('Monomorphemic lexicons correlation value') +theme(legend.position = "none")+ggtitle("Correlations between phon/ortho. prob. and frequency")+ geom_abline(intercept = 0, slope =1, alpha=.4)
ggsave('~/wiki_celex_prob_f.pdf', width=5.5, height=5.5)
