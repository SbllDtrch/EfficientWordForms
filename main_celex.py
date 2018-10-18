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
import copy
from lm import *
from nphone import NgramModel
from nsyll import NsyllModel
from pcfg import PCFG
#from bigmatch import BigMatch
#from kn import *
from evaluation import *
from generation_srilm import *
from perplexity import *
from subprocess import call
import multiprocessing


try:
    os.mkdir('Lexicons')
except OSError:
    pass

try:
    os.mkdir('matchedLexica')
except OSError:
    pass

try:
    os.mkdir('Graph')
except OSError:
    pass

try:
    os.mkdir('evaluation')
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
	n = 5
	smoothing = 0.01
	iterations = 1000
	homo= 0
	lex = [i.strip().split("\t") for i in open(lexicon, "r").readlines()[1:]]
	corpus = [i.strip().split("\t")[0] for i in open(lexicon, "r").readlines()[1:]]
	fnc = "generate"

	length = nltk.defaultdict(int)
	for c in corpus:
	    length[len(c)] +=1

	print length
	print model, len(corpus), "sample", corpus[0]
	#lm = NgramModel(n, corpus, 1)
	lm3 = NgramModel(3, corpus, 1)
	#lm.create_model(corpus, smoothing)
	lm3.create_model(corpus, smoothing)
	o = "Lexicons/sim_" + lexicon.split("/")[-1][:-4] + "_iter" + str(iterations) + "_m" + model + "_n" + str(n) + "_smoothing" + str(smoothing) + ".txt"
	#lexfile = write_lex_file(o, corpus, lex, iterations, lm, homo, lm3)
	lexfile = write_lex_file_srilm(o, corpus, lex, lang, iterations, n, smoothing, lm3)

if __name__ == '__main__':

	parser = argparse.ArgumentParser()
	parser.add_argument('--n', metavar='--n', type=int, nargs='?', help='array index', default=0)
	args = parser.parse_args()
	
	lang = ['english','french','dutch','german']
	lexicon = ['celex/out_freq__lemma_'+i+"_1_0_0_40.txt" for i in lang]
	multi(lexicon[args.n], lang[args.n])
