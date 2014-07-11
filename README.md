# PedPlus

A Web application for counting pedestrians and modeling walkability.

## Architecture

This repository provides all dependencies for desktop/tablet web app, JSON REST API, and server-side accessibility models. See [PedCount](https://github.com/drewda/pedcount) for the accompanying mobile app.

  
                     +-------------------------------------+
                     |     PedPlus Ruby on Rails web app   |
                     |-------------------------------------|             +-------------------+
                     |                                     |             |PedCount mobile app|
                     |    +-----------------------------+  |      +------+(PhoneGap)         |
                     |    |desktop/tablet interfaces    |  |      |      +-------------------+
                     |    |(CoffeeScript and BackboneJS)|  |      |
                     |    ++----------+-----------------+  |      |
                     |     |          |                    |      |
                     |     |    +-----+-------+            |      |
                     |     |    |JSON REST API+-------------------+
                     |     |    +-------------+            |             +--------------------+
         +-----------+     |                               +-----+       |accessibility models|
         |           |     |                               |     |       |(Python)            |
         |           +-----|-+--------------+--------------+     |       +---------+--+-------+
         |                 | |              |                    |                 |  |
         |                 | |              |                    |                 |  |
         |                 | |              |                    |                 |  |
     +---+----+      +-----+-+-+         +--+--+               +-+-------+         |  |
     |MySQL   |      |Node push|         |Redis|               |Resque   |         |  |
     |database|      |server   +---------+cache+---------------+job queue+---------+  |
     +---+----+      +---------+         +-----+               +---------+            |
         |                                                                            |
         +----------------------------------------------------------------------------+


## Dependencies
* Ruby 1.9
* MySQL
* Redis (for caching)
* Node.js, npm, Juggernaut (for push notification)
* Python 2.7, NetworkX, PyYAML, Python-MySQL
* pyqt (is required for capybara-webkit, which is used for testing)

## "Easy" Installation

If you'd like to try a subset of PedPlus functionality, follow [these instructions](https://github.com/drewda/pedplus/blob/heroku/README.markdown) to install a working version on the [Heroku](https://www.heroku.com/) hosting service.
  
## Credits
Developed by Drew Dara-Abrams in 2011 - 2012, with urban-planning assistance from Joao Pinelo and visual design assistance from Victor Schinazi. Copyright 2011 - 2012 Strategic Spatial Solutions, Inc. Released under the GPLv3 license.