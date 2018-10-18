from nltk import *
import random, sys, re, os
import nltk
import argparse
import itertools
#import Levenshtein
import time, datetime
import pickle
t = time.time()
import collections
#from calc_stats import *
import copy
from lm import *
from nphone import NgramModel
#from bigmatch import BigMatch
#from kn import *
from generation import *
from perplexity import *
from subprocess import call
import multiprocessing


try:
    os.mkdir('Lexicons')
except OSError:
    pass


def calc_neigh(w, lex):
    neigh = 0
    mp =0
    neigh_list = []
    for item in lex:
        lev = Levenshtein.distance(w, item[0])
        if lev == 1:
            neigh += 1
            neigh_list += [item[1]]
            if len(item[0]) == len(w):
                mp +=1
    return mp, neigh, neigh_list

def multi(lexicon, lang):
	model = "ngram"
	n = 7
	smoothing = 0.01
	iterations = 1000
	lex = [i.strip().split("\t") for i in open(lexicon, "r").readlines()[1:]]
	corpus = [i.strip().split("\t")[0] for i in open(lexicon, "r").readlines()[1:]]
	fnc = "generate"

	length = nltk.defaultdict(int)
	for c in corpus:
	    length[len(c)] +=1

	print length
	print model, len(corpus), "sample", corpus[0]
	lm3 = NgramModel(3, corpus, 1)
	lm3.create_model(corpus, smoothing)
	o = "Lexicons/sim_" + lexicon.split("/")[-1][:-4] + "_iter" + str(iterations) + "_m" + model + "_n" + str(n) + "_smoothing" + str(smoothing) + ".txt"
	lexfile = write_lex_file_srilm(o, corpus, lex, lang, iterations, n, smoothing, lm3)

if __name__ == '__main__':
	parser = argparse.ArgumentParser()
	parser.add_argument('--n', metavar='--n', type=int, nargs='?', help='index of lang_all array -- this has been implemented this way to submit array jobs', default=1)
	args = parser.parse_args()

	lang_all = ['af','bg','cv','fa','hif','ja','lmo','my','pl','simple','tg','vo','als','bn','cy','fi','hr','jv','lt','mzn','pms','sk','th','wa','am','bpy','da','fr','ht','ka','lv','nap','pnb','sl','tl','war','an','br','de','fy','hu','kk','mg','nds','pt','sq','tr','yi','ar','bs','el','ga','hy','kn','min','ne','qu','sr','tt','yo','arz','bug','en','gd','ia','ko','mk','new','ro','su','uk','zh','ast','ca','eo','gl','id','ku','ml','nl','ru','sv','ur','az','ceb','es','gu','io','ky','mn','nn','scn','sw','uz','ba','ckb','et','he','is','la','mr','no','sco','ta','vec','be','cs','eu','hi','it','lb','ms','oc','sh','te','vi']

	exclude = ['gu', 'te', 'ta', 'bpy', 'zh', 'new', 'bn', 'ja', 'hi', 'ml', 'mr', 'my', 'ne', 'kn','ko', 'simple','eo','ia','io','vo']
	lang = [x for x in lang_all if x not in exclude]
	print len(lang), lang
	multi('wiki/out_'+lang[args.n-1]+".txt", lang[args.n-1])
