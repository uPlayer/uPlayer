
# uPlayer [![Build Status](https://travis-ci.org/uPlayer/uPlayer.svg?branch=master)](https://travis-ci.org/uPlayer/uPlayer)
A audio player for Mac Os x.  

Last.fm scrobbling and global key blinding is supported.

![uPlayer](res/uPlayerScreen.png)

##Download  

[Latest Releases](https://github.com/uPlayer/uPlayer/releases/latest)  

##Advance fetures  

* Global key blinding:  
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




##How to build This Project  

1. Clone this project 

		git clone https://github.com/uPlayer/uPlayer.git 
	
	  And update the git submodule:

2. Download and build [jsoncpp](http://sourceforge.net/projects/jsoncpp/) and [taglib](https://tablib.readthedocs.org/en/latest/)  

3. Done and Open the project with xcode.

##ToDo

* The lyrics showing thing.  

* Change a better application's icon.  

* Reload Itunes Media , changed . 改进算法,using last modified time.  

* The Font Changing. 

##Draft a new release 

1. Change the `bundle version` to v0.a.x and `Bundle version string,short` to 0.a.x  

2. Create a new git tag  0.a.x  

3. Draft a new release in github with title `uPlayer-0.a.x`.


##License  

[![by](https://creativecommons.org/images/deed/by.png)![](https://creativecommons.org/images/deed/nc.png)![](https://creativecommons.org/images/deed/sa.png)](http://creativecommons.org/licenses/by-nc-sa/3.0)

  




