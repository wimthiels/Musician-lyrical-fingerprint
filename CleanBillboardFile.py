# -*- coding: utf-8 -*-
"""
Created on Sat Oct 21 15:23:19 2017
this script cleans up the billboard file for further processing
1) drop the 'featuring' : so 'elton john featuring madonna' becomes 'elton john'
@author: Wim Thiels
"""

import pandas as pd

#step 1 get rid of 'featuring' and ' and ' in artistname
df_billboard = pd.read_csv(
    'billboard_lyrics_1964-2015_original.csv', encoding='latin-1')

df_billboard['Artist']=df_billboard['Artist'].str.split(' feat').str.get(0).str.strip()
#df_billboard['Artist']=df_billboard['Artist'].str.split(' and ').str.get(0).str.strip()

#remove punctuation in lyrics and set to lowercase
df_billboard['Lyrics'] = df_billboard['Lyrics'].str.lower().str.replace(r'.,',' ').str.strip()

#write output
df_billboard.to_csv('billboard_lyrics_1964-2015.csv')

