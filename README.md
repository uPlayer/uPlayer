
# uPlayer [![Build Status](https://travis-ci.org/uPlayer/uPlayer.svg?branch=master)](https://travis-ci.org/uPlayer/uPlayer)

![uPlayer](res/uPlayer.png)

A audio player for Mac Os x.  



Last.fm scrobbling and global key blinding is supported.

##Download  

[Latest Releases](https://github.com/uPlayer/uPlayer/releases/latest)  

##Advance fetures  

* About global key blinding:  
uPlayer use a json format config file.  
You can find it in Menu uPlayer/KeyBlindings.  
This is the default codes:  

		{
		  "super+d" : "to_play_random",
	      "super+e": "to_play_pause_resume"
		}

You can change it yourself. Make sure all words is *lowecased*.

* Last.fm:  
	 
	 * uPlayer will scrobble songs when played half of time or 40 seconds.  
	 * uPlayer will send "nowPlaying" message to last.fm when a track started.
	 * You can also mark a song loved via menu "Love @ Last.fm"

##System  

Only tested in OS X 10.10 Yosemite  


##ToDo

* The lyrics showing thing.  
	 Something it may be a good thing.  
   Seeing the lyrics may change the taste of a good song. ~_~  
* Change a better application's icon.


##Draft a new release 

1. Change the `bundle version` to v0.a.x and `Bundle version string,short` to 0.a.x
2. Create a new git tag  0.a.x
2. Draft a new release in github with title `uPlayer-0.a.x`.



##License  

[![by](https://creativecommons.org/images/deed/by.png)![](https://creativecommons.org/images/deed/nc.png)![](https://creativecommons.org/images/deed/sa.png)](http://creativecommons.org/licenses/by-nc-sa/3.0)

  




