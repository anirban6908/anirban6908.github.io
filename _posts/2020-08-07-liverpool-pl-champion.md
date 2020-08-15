---
layout: single
title:  "A look into the EPL 2019-20 season"
excerpt: Visualizing Liverpool's dominance over the 2019-20 English Premier League season
classes: wide
header:
    teaser: /assets/posts/lfc_2019_20/lfc_parade.jpg
categories: [Soccer]
tags: [Visualization, R]
comments: true
permalink: /blog/lfc-champions-2020/
share: true
---

This has been a truly historic premier league season. Disclaimer: I am an ardent Liverpool FC supporter which made the season doubly special. After 30 long years Liverpool Football Club (LFC) has finally become the premier league champions. B/R Football made an extremely touching animation celebrating this occasion. 
{% include video id="LWJ5D16hX3U" provider="youtube" %}
After the heartbreak of last year when LFC ended just 1 point behind Manchester City, I was starting to feel this may never happen. But just like last year when Liverpool went on to win the Champions League after collapsing against Real Madrid the year before, they came back stronger this season domestically and completely blown away the competitors. 

This is how the season ended: Liverpool with 99 points, City finishing second with a massive 18 points difference. Manchester United and Chelsea claimed the rest of the top 4 postions while Bournemouth, Watford and Norwich got relegated. I made this table using the [formattable](http://renkun-ken.github.io/formattable/) and sparkline package in R.

<div>
    <iframe src="points_table.html" width="100%" height="750" style="border:none;" ></iframe>
</div>

## Race to become Champion

It was a nailbitingly close premier league season last year (on the final day Brighton was up against Man City for a little while and Liverpool were winning against Wolves), I was once again expecting a competitive season with Liverpool and Man City being the main contenders and Champions League finalists Spurs as outside challengers. It started pretty close but Liverpool quickly opened up a 9 point lead with a 3-0 home win against City at Anfield. To my surprise City stumbled quite often as you can see in graph below (reqd. C'ship points threshold kept going down) while the LFC juggernaut rolled on. In the end it was only a formality before Liverpool would be champions. With the COVID-19 pandemic there was a scare that the season would be voided as some other european leagues. It'd have been extremely cruel since Liverpool only needed a couple of wins to clinch the title but thankfully after a lengthy layover the season resumed in June. And it only took a couple of games with Chelsea handing Liverpool the title by beating City on game week 31.
<div>
    <iframe src="epl_points_by_week.html" width="100%" height="700" style="border:none;" ></iframe>
</div>


## Home and Away Records
This was truly a remarkable season as a Liverpool fan. The sheer number of points amassed as well as the dominance shown by LFC made it worth the wait. As good as they were ([records set by Liverpool](https://www.premierleague.com/news/1561869)), there were some near misses in terms of setting records. 

* Invincibility - Arsenal keeps the record for now. I was hopeful until an off day against eventually relegated Watford saw Liverpool registering their first loss of the season. They lost couple more times to Man City and Arsenal in the final few weeks after wrapping up the title.

* Century of points - Man City's record of 100 points in a season stayed intact with LFC coming within 1 point of that tally.

* Perfect Home Record and Number of Home wins - Liverpool missed out on both by drawing against Burnley at a post COVID empty Anfield.

The fact that these ridiculous records were within reach tells you how amazing the campaign was for LFC (55 home points out of possible 57!). I believe the near miss of last season was definitely a motivating factor in keeping up such high standards.

<div>
    <iframe src="points_breakup.html" width="100%" height="700" style="border:none;" ></iframe>
</div>


## Some Statistics for the Top 4 
The following radar plot made using ggradar package shows some statistics for the top 4 (normalized against all 20 teams). As previous years City dominated the attacking metrics with the rest of top 4 in close competition. Liverpool had a number of close margin victories where the defensive prowess helped them get over the line. This is seen in the Shots Against (On Target), Goals Against, Corners Against metrics for Liverpool. The metric abbreviations are detailed here.


| GF 	| GA 	| SF 	| SA 	| STF   | STA   | CF    | CA 	| FF    | FA    | 
|:-----:|:-----:|:-----:|:-----:|:-----:|:-----:|:-----:|:-----:|:-----:|:-----:|
|Goals<br>For|Goals<br>Against|Shots<br>For|Shots<br>Against|Shots on<br>Target For|Shots on<br>Target Against|Corners<br>For|Corners<br>Against|Fouls<br>Awarded|Fouls<br>Committed|

<figure>
	<img src="/assets/posts/lfc_2019_20/stat_radar.png" height="400" width="100%" align="left">
</figure>>



## Back on our perch

It's good to be at the pinnacle of English Football once again (at the time of writing this blog post, we are also the European and World Champion). The following heatmap constructed using the leaflet package shows the domestic league success across the clubs. Even with a late start, Liverpool are now 1 championship away from catching up to Man United (20 league titles). The data for this visualization is scraped from the [wiki page](https://en.wikipedia.org/wiki/List_of_English_football_champions) using rvest package.

<div>
    <iframe src="cship_region.html" width="100%" height="700" style="border:none;" ></iframe>
</div>

The codes for this blog is available [here](https://github.com/anirban6908/anirban6908.github.io/tree/master/assets/codes/lfc_2019_20)

## References
* Integrating sparkline with formattable ([link](https://www.displayr.com/formattable/))
* Using rvest to scrape webpages ([link](https://www.r-bloggers.com/using-rvest-to-scrape-an-html-table/))
* Data for the EPL season is taken from the following [website](https://www.football-data.co.uk/englandm.php).