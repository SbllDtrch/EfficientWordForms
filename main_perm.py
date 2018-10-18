from nltk import *
import random, sys, re, os
import nltk
import argparse
import itertools
import Levenshtein
import time, datetime
import pickle
t = time.time()
import collections
import copy
from lm import *
from nphone import NgramModel


def perm(lexicon, lang):
	iter =1000
	lex = [i.strip().split("\t") for i in open(lexicon, "r").readlines()[1:]]
	
	#select only words length 3 to 7
	selected_lex = []
	for c in lex:
		if int(c[15]) >= 3 and int(c[15]) <=10:
			selected_lex += [c]

	print len(selected_lex)
	o = "celex_perm/sim_perm_" +lang +".txt"
	outfile  = open(o, "w")
	outfile.write(",".join(["lex","word","count","prob","mps","length","lang"]) + "\n")
	freqs = nltk.defaultdict(list)
		
	for c in selected_lex:
        	outfile.write(",".join(str(x) for x in [-1,c[0],c[1],c[2],c[3],c[15], lang]) + "\n")
		freqs[len(c[0])] += [c[1]]

	for i in range(iter):
    		temp_freqs = nltk.defaultdict(list)
		for k in freqs.keys():
			temp_freqs[k] = list(freqs[k])
			random.shuffle(temp_freqs[k])
	
		for c in selected_lex: 
			freq_w = temp_freqs[len(c[0])][-1]
			del temp_freqs[len(c[0])][-1] 
			outfile.write(",".join(str(x) for x in [i,c[0],freq_w,c[2],c[3],c[15], lang]) + "\n")
        	print "generated lexicon: ", str(i)
	outfile.close()


if __name__ == '__main__':
	parser = argparse.ArgumentParser()
	parser.add_argument('--n', metavar='--n', type=int, nargs='?', help='array index', default=0)
	args = parser.parse_args()

	lang_all = ['af','bg','cv','fa','hif','ja','lmo','my','pl','simple','tg','vo','als','bn','cy','fi','hr','jv','lt','mzn','pms','sk','th','wa','am','bpy','da','fr','ht','ka','lv','nap','pnb','sl','tl','war','an','br','de','fy','hu','kk','mg','nds','pt','sq','tr','yi','ar','bs','el','ga','hy','kn','min','ne','qu','sr','tt','yo','arz','bug','en','gd','ia','ko','mk','new','ro','su','uk','zh','ast','ca','eo','gl','id','ku','ml','nl','ru','sv','ur','az','ceb','es','gu','io','ky','mn','nn','scn','sw','uz','ba','ckb','et','he','is','la','mr','no','sco','ta','vec','be','cs','eu','hi','it','lb','ms','oc','sh','te','vi']

	exclude = ['gu', 'te', 'ta', 'bpy', 'zh', 'new', 'bn', 'ja', 'hi', 'ml', 'mr', 'my', 'ne', 'kn','ko', 'simple','eo','ia','io','vo']
	lang = [x for x in lang_all if x not in exclude]
	lang = ['pnb']
	print len(lang), lang
#	perm('celex/out_freq__lemma_'+lang[args.n-1]+"_1_0_0_40.txt", lang[args.n-1])
	perm('wiki/out_'+lang[args.n-1]+".txt", lang[args.n-1])
