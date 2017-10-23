# -*- coding: utf-8 -*-
"""
Created on Tue Oct 17 20:41:48 2017
Webscraping artist info off off Allmusic.com
get all the data into a dataframe, and output a csv-file
@author: Wim Thiels
"""
#IMPORTS#################################################
import pandas as pd
from datetime import datetime
from selenium import webdriver
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.chrome.options import Options

medion_swith = False  #false for asus laptop

#get webdriver with adblocker#################################

path_to_extension = r'C:\Users\Administrator\AppData\Local\Google\Chrome\User Data\Default\Extensions\gighmmpiobklfepjocnamgkkbiglidom\3.18.0_0'
if medion_swith:
    path_to_extension = r'C:\Users\wim\AppData\Local\Google\Chrome\User Data\Default\Extensions\gighmmpiobklfepjocnamgkkbiglidom\3.18.0_0'
chrome_options = Options()
chrome_options.add_argument('load-extension=' + path_to_extension)
if medion_swith:
    chrome_path = r"C:\Users\wim\Downloads\chromedriver_win32\chromedriver.exe"
else:
    chrome_path = r"C:\Program Files\chromedriver_win32\chromedriver.exe"
driver = webdriver.Chrome(chrome_path, chrome_options=chrome_options)
driver.create_options()

#init###############
df_billboard = pd.read_csv(
    'billboard_lyrics_1964-2015.csv', encoding='latin-1')
l_artist = df_billboard['Artist'].drop_duplicates()
#l_artist = df_billboard.loc[1:20, 'Artist']

open("ScrapeAllmusicRaw.txt", 'w').close()  # empty the log files
open("ScrapeAllmusicErrorLog.txt", 'w').close()

# maximum number of strings that i'm gonna retain from the page per topic
d_topic_maxEl = {'genre': 2, 'style': 5, 'mood': 10}

rowFields=[]
for topic in d_topic_maxEl:
    key_topic = [''.join([topic, str(i)])
                 for i in range(1, d_topic_maxEl.get(topic) + 1)]
    rowFields += key_topic
    
d_d_total = {}

# navigate to website
driver.get("https://www.allmusic.com/")

# just a raw outputfile for logging various output (can be removed)


def write_output(key, info):
    record = ('##').join([key, info])
    print(record, file=open("ScrapeAllmusicRaw.txt", "a", encoding="utf-8"))
    return record


# keep an errorlog
def write_error(key, programlocation, exception):
    template = "An exception of type {0} occurred. Arguments:\n{1!r}"
    message = template.format(type(exception).__name__, exception.args)
    record = ('##').join([key,programlocation, message])
    print(record, file=open("ScrapeAllmusicErrorLog.txt", "a", encoding="utf-8"))
    return record


# finds the searchbox and fills in the artistname and presses <ENTER>
# output :  webelement of the artist (or None)
def A010_find_artist_by_searchbox(artist):
    print('$$' + 'A010_find_artist_by_searchbox' + artist)
    try:
        searchBox = WebDriverWait(driver, 100).until(
            EC.element_to_be_clickable((By.CLASS_NAME, "site-search-input")))
        print('$$A010 $after first wait')
        searchBox.send_keys(artist)
        searchBox.send_keys(Keys.ENTER)
        WebDriverWait(driver, 100).until(EC.visibility_of_element_located(
            (By.CSS_SELECTOR, "*[class^='search-result']")))  # wait for a random field below the page to load
        print('$$$A010 after second wait')
        return driver.find_element_by_css_selector("*[href^='https://www.allmusic.com/artist']")
    except Exception as ex:
        print(write_error(artist, 'A010', ex))
        return None

# on the artistpage it will scrape the info for 1 particular topic eg 'genre'
# all the data is stored in a dictionary d_row
def B010_store_topic_info(topic, artist):
    searchString = ''.join(["""*[href^='https://www.allmusic.com/""", topic])
    l_el_topic = driver.find_elements_by_css_selector(
        searchString)

    for idx, topic_element in enumerate(l_el_topic):
#        write_output(artist, topic_element.text)
        if idx < d_topic_maxEl.get(topic):
            key = ''.join([topic, str(idx + 1)])
            d_row[key] = topic_element.text


# input : webelement of artist and artistname
# action : clicks the artist, and then scrapes all the data
def A020_scrape_data_for_1_artist(artistLink, artist):

    try:
        artistLink.click()
        WebDriverWait(driver, 100).until(EC.presence_of_element_located(
            (By.CSS_SELECTOR, "*[href^='https://www.allmusic.com/genre']")))
        
        
        for topic in d_topic_maxEl.keys():
            B010_store_topic_info(topic, artist)
            
    except Exception as ex:
        print(write_error(artist, 'A020', ex))
        return None


# MAIN--------------------
if __name__ == '__main__':
    for idx,artist in enumerate(l_artist):
        d_row = {}
        if idx%100==0: write_output(artist, " still running at " + str(datetime.now()))
        print("$$main start with " + artist)
        artistLink = A010_find_artist_by_searchbox(artist)
        if not artistLink:    
            # try again with a short name of first 2 words
            artist_split = artist.split()
            if len(artist_split) > 2:
                if artist_split[0] == 'the':
                    artist_short = artist_split[1] + " " + artist_split[2]
                else: 
                    artist_short = artist_split[0] + " " + artist_split[1]
                print('$$main : try again with shortname' + artist)
                artistLink = A010_find_artist_by_searchbox(artist_short)
            else:
                artist_extended = "artist" + artist
                artistLink = A010_find_artist_by_searchbox(artist_extended)
            if not artistLink:
                print('$$main : could not find any info on ' , artist)
                continue  
        if artistLink:
            A020_scrape_data_for_1_artist(artistLink, artist)
            
        d_d_total[artist]=d_row
        
    df = pd.DataFrame.from_dict(d_d_total,orient='index')   
    df.to_csv('artistScrape.csv')
    df.to_pickle('artistScrape.pkl')

    print('$$goodbye')
