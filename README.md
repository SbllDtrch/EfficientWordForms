# EfficientWordForms
Data repository for Mahowald, K., Dautriche, I., Gibson, E. &amp; Piantadosi, S.T. (2018). Word Forms Are Structured for Efficient Use. Cognitive Science: 1-19 (https://onlinelibrary.wiley.com/doi/10.1111/cogs.12689)

This repository contains all the necessary files to generate random lexicons and compare the correlations freq/phonotactics and freq/neighborhood density found in these simulations and the true correlations found in the real lexicons. Because the simulations are very heavy files (10000 simulated lexicons for each language), they are not included here but can be generated using the instructions below.
srilm library needs to be downloaded in local with path updated in perplexity.py


# analysis.r Generate graphs and analysis found in the paper

# celex
Folder containing the correlations for the 4 celex lexicons.
## out_* individual files containing stats for each of the most frequent 20000 words of a given lexicon
## celex_real_lex_corr.txt correlations for each length in the real lexicons
## celex_results.txt correlations and stats for each length and each lexicon (simulated lexicons method)
## celex_results_perm.txt correlations and stats for each length and each lexicon (permuted lexicon method — does not appear in the paper)

# evaluation.py/generation.py/lm.py/nphone.py/perplexity.py Functions used by main_*.py to generate and evaluate the null lexicons.

# get_stats.R compute the correlations from the out_*.txt files and the stats comparing real and simulated lexicons 

# languages_studied_updated.csv wiki codes with associated language name and language family

# Lexicons. Folder for the simulated lexicons once generated (empty for the sake of space)

# main_wiki.py main script used to generate the simulated lexicons for the wiki corpus. Use the following command line to make it work:

python main_wiki.py --n i

Where i stands for the array index of the list of available language (see in the file), this is easy to manipulate on a cluster where you can send job array.

# main_celex.py main script used to generate the simulated lexicons for the 4 celex lexicons.

# main_perm.py main script used to generate the permuted lexicons (analysis not included in the paper)

# wiki
Folder containing the correlations for the wiki corpora.
## out_*.txt file for individual language listing the 20,000 most frequent words and their stats.
## wiki_real_lex_corr.txt correlations for each length in the real lexicons
## wiki_results.txt correlations and stats for each length and each lexicon (simulated lexicons method)
## wiki_results_perm.txt correlations and stats for each length and each lexicon (permuted lexicon method — does not appear in the paper)
