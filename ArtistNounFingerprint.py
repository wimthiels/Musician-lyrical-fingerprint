# -*- coding: utf-8 -*-
"""
Created on Sat Oct 21 12:43:25 2017
script that will count the nouns that each artist uses based on billboard data
step1 : go over each song, filter out the nouns (based on nouns.txt)
step2 : count the words and add them to a running total for that artist
step3 : at the end normalise the count so it becomes an mpf (mass prob function)
step4 : export is to a csv with rownames = artist , colnames = all the nouns used 
=> so a noun-fingerprint for each artist

datastructure : a dict of dicts : 
        key of outerdict = artistname, 
        key of innerdict = noun
@author: Wim Thiels
"""
import pandas as pd
from collections import defaultdict

d_artist_d_nouns = defaultdict(dict)

df_billboard = pd.read_csv(
    'billboard_lyrics_1964-2015.csv', encoding='latin-1')

##temp
##df_billboard = df_billboard[1:20]

nouns = set(open('nounlist.txt','r').read().split('\n'))
nouns.remove('if')
nouns.add('i')

def normalize_noun_count(d):
    return {k:v/sum(d.values()) for k,v in d.items()}

# MAIN--------------------
if __name__ == '__main__':
    #step1 : counting the words
    for song in df_billboard.itertuples(): #iterate row by row in named tuple format
        for word in str(song.Lyrics).split():
            if word in nouns:
                #if the artist doesn't exist it will create a new empty dictionary
                #if the word doesn't exist it will initialize with 0
                d_artist_d_nouns[song.Artist][word] = d_artist_d_nouns[song.Artist].get(word,0) + 1

    #step2 : normalizing to get a mdf
    d_artist_d_nounsnorm = {k:normalize_noun_count(v) for k,v in d_artist_d_nouns.items()}

    #step3 : exporting to csv
    df = pd.DataFrame.from_dict(d_artist_d_nounsnorm,orient='index')   
    df.to_csv('artistNounFingerprint.csv')
    df.to_pickle('artistNounFingerprint.pkl')
    
    print('**goodbye')
        
        
