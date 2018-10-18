from evaluation import *
import random, sys, re
import nltk
import itertools
import numpy as np   
import Levenshtein
from perplexity import *


def get_mps(lexicon):
	mps = nltk.defaultdict(int)
	for item in itertools.combinations(lexicon, 2):
		if len(item[0]) == len(item[1]):
			lev = Levenshtein.distance(item[0], item[1])
                        #lev = levenshtein(item[0], item[1])
			if lev == 1:
				mps[item[0]] +=1
				mps[item[1]] +=1
	return mps
			

def get_lm_model_srilm(lexicon, lang, order=3, smoothing='wbdiscount', add=.1):
    srilm_lexicon = [" ".join(list(w)) for w in lexicon]
    srilm_lexicon  = turn_to_txt(srilm_lexicon, lang)
    a = [ngramcount, '-text', srilm_lexicon, '-lm', lang+'.lm', '-order', str(order)] 
    for o in range(1, order + 1):
        if smoothing == 'addsmooth': 
            a += ['-' + smoothing + str(o), str(add), '-gt'+str(o)+'min', '0']
        else: a += ['-' + smoothing + str(o), '-gt'+str(o)+'min', '0']

    rv = subprocess.call(a)
                                                                                                                                            
def generate_correct_number_srilm(corpus, lang, lengths, freqs, order):
    newwords = []
    exist = nltk.defaultdict(int)
    curr_lengths = nltk.defaultdict(int)
    newfreqs = nltk.defaultdict(int)
    n_words = len(corpus)
    counter = 0
    while True:
        counter +=1
        b = [ngram, '-lm', lang+'.lm', '-order', str(order), '-gen', str(1000)]
        proc= subprocess.Popen(b, stdout=subprocess.PIPE)
        out, err = proc.communicate()
        del proc
        words = []
        out = "".join(str(x) for x in out)
        for i in out.split("\n"):
            words += ["".join(str(x) for x in i.split(" "))]
        words = set(words)
        words=list((set(newwords)^words)&words)
        for w in words:
            if curr_lengths[len(w)] < lengths[len(w)] > 0:
                if w not in newwords:
                    curr_lengths[len(w)] += 1
                    if len(newwords) %1000 == 0:
                        print len(newwords)
                    newwords += [w]
        	    newfreqs[w] = freqs[len(w)][-1]
                    del freqs[len(w)][-1]
                    if w in corpus:
                        exist[len(w)] +=1
            elif n_words == len(newwords): 
                print "nb of real words", sum(exist.values())
                return newwords, newfreqs


def write_lex_file_srilm(o, corpus, lex, lang, iter, order, smoothing, lm3):
    get_lm_model_srilm(corpus, lang, order, 'addsmooth', smoothing)

    outfile  = open(o, "w")
    lengths_needed = nltk.defaultdict(int)
    freqs = nltk.defaultdict(list)

    for c in lex:
        outfile.write(",".join(str(x) for x in [-1,c[0],c[1],c[2],c[3],c[15]]) + "\n")
	lengths_needed[len(c[0])] += 1
	freqs[len(c[0])] += [c[1]]

    for i in range(iter):
    	temp_freqs = nltk.defaultdict(list)
	for k in freqs.keys():
		temp_freqs[k] = list(freqs[k])
		random.shuffle(temp_freqs[k])	
        gen_lex, freqs_lex= generate_correct_number_srilm(corpus, lang, lengths_needed, temp_freqs, order)
	mps_lex = get_mps(gen_lex)
        for w in gen_lex:
            outfile.write(",".join(str(x) for x in [i,w,freqs_lex[w], lm3.evaluate(w)[2],mps_lex[w], len(w)]) + "\n")
        print "generated lexicon: ", str(i)
    outfile.close()
    return o


