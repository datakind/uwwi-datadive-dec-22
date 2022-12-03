# Notes: 
# https://www.aakashweb.com/articles/google-news-rss-feed-url/
# https://newscatcherapi.com/blog/google-news-rss-search-parameters-the-missing-documentaiton


import feedparser
from datetime import datetime
import json
import argparse


parser = argparse.ArgumentParser(description='Command Line Arguments For ' +
                                 'Driver Code')
parser.add_argument('--search', required=True,
                    help='search type can either be: "title", or "geo"')
argument = parser.parse_args()
searchoption = argument.search

datem = datetime.today().strftime("%Y-%m-%d")
if searchoption == "title":
    searchchoice = "https://news.google.com/rss/headlines/section/search?q=wisconsin+after:2019-01-01+before:","gnewsbytitle"
else:
    searchchoice = "https://news.google.com/rss/headlines/section/search?q=wisconsin+"+str(searchoption)+"+after:2019-01-01+before:","gnewsby"+str(searchoption)

def monthToNum(shortMonth):
    return {
            'Jan': "01",
            'Feb': "02",
            'Mar': "03",
            'Apr': "04",
            'May': "05",
            'Jun': "06",
            'Jul': "07",
            'Aug': "08",
            'Sep': "09", 
            'Oct': "10",
            'Nov': "11",
            'Dec': "12"
    }[shortMonth]

def rssapi(beforedate,searchchoice):
    NewsFeed = feedparser.parse(searchchoice+beforedate+"&ceid=US:en&hl=en-US&gl=US")
    entry = NewsFeed.entries
    newsinfo = {}
    for news in entry:
        newsinfo["title"] = news["title"]
        newsinfo["title_detail"] = news["title_detail"]
        newsinfo["links"] = news["links"]
        newsinfo["link"] = news["link"]
        newsinfo["published"] = news["published"]
        newsinfo["source"] = news["source"]
        print(news["title"])
        print(news["published"])
    yearvar = str(entry[-1]["published"].split(" ")[3])
    monthvar = monthToNum(entry[-1]["published"].split(" ")[2])
    datevar = str(entry[-1]["published"].split(" ")[1]) 
    rssafterdate = yearvar+"-"+monthvar+"-"+datevar
    return rssafterdate, entry[-1]["published"].split(" ")[3], newsinfo

def generatenewstitles():
    rssafterdate = rssapi(datem,searchchoice[0])
    gnewdata = []
    datechecker = False
    while datechecker == False:
        rssafterdate = rssapi(rssafterdate[0],searchchoice[0])
        gnewdata.append(rssafterdate[2])
        if rssafterdate[1] == "2019":
            datechecker = True
            with open(searchchoice[1]+".json","w") as jdata:
                json.dump(gnewdata,jdata,indent=4)
            print("saved data to json")
generatenewstitles()
