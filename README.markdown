# PedCount/PedPlus

A Web application for counting pedestrians. To use, this must be hosted on a server.

## To Install on Heroku

Note that this assuming that you are using a Mac. The instructions are pretty much the same on Linux. Some skill might be required to adapt them for Windows.

1. Heroku prerequisites

    a.  [Sign up for a free Heroku account.](https://api.heroku.com/signup)
    
    b.  Download and install the [Heroku Toolbelt](https://toolbelt.heroku.com/).

2. Github prerequisites

    a. [Sign up for a free Github account.](https://github.com/signup/free)
    b. Download and install [Github for Mac](http://mac.github.com/).
    
3. Ruby prerequisites

    a. This software runs best using Ruby 1.9.3. Your Mac may be running an older version of Ruby. To check its version, open the Terminal application and run the command `ruby -v`
    
    b. If you are not running Ruby 1.9.3 the simple way to install it may be with [the RailsInstaller package](http://railsinstaller.org/#osx). Follow its installation instructions.

4. MySQL prerequisites

    a. If you want to be able to run this application locally on your computer (for testing purposes), you will need to install the MySQL database.
    
    b. Download the latest version of [the MySQL Community Server](http://www.mysql.com/downloads/mysql/) and run its installer.
    
    c. Either select to automatically start the MySQL server every time your computer boots or remember to manually start it each time you want to use the Rails application.


5. Download this code to your computer
  
    a. Open a Web browser to https://github.com/s3sol/pedplus
    
    b. Press the *Clone in Mac* button and select a local folder on your computer to place the code.
    
6. Configure and deploy to Heroku

    a. Change into the new "pedplus" folder
    
    b. Switch to the "heroku" branch of the source code by running `git checkout heroku`

    c. Log in to Heroku by running `heroku login`
    
    d. Create a new application on Heroku by running `heroku create`
    
    e. Deploy the code to Heroku by running `git push heroku heroku:master`
    
    f. Seed the database with an initial user account and organization by running `heroku run rake db:seed`
    
7. Test the server
    
    a. Open the Web application in your Web browser by running `heroku open` (This URL should also have been listed at the end of the deploy process in Step 6e.)
    
    b. Sign in using the sample account you created in Step 6f: Its e-mail address is "user@sample.com" and its password is "changeme"
    
    c. You can change this and other account information through the admin interface by adding `/admin` to the end of the root URL. The sample account has been given admin privileges.
    
8. Modifying Heroku settings

    * To rename the application (and its hostname), run the following command: `heroku apps:rename this_is_my_new_name`
    
    * To use a non-Heroku domain name for your application, follow the steps in [this article on the Heroku site](https://devcenter.heroku.com/articles/custom-domains).
    
    * To diagnose problems with the application, examine the server logs by running this command: `heroku logs`
    
    
## Technical Details

### Server Side

This is a [Ruby on Rails](http://rubyonrails.org/) application. Its server-side components are written in the [Ruby scripting language](http://www.ruby-lang.org/). Data is written to the [MySQL database](http://mysql.com/). (Or if the application is hosted on Heroku, it's written to the [Postgres database](http://www.postgresql.org/).) A number of Ruby software libraries (known as "gems") are used in the application; for a full list read the [Gemfile](https://github.com/s3sol/pedplus/blob/heroku/Gemfile) in the root folder. More information on these gems can be looked up at [rubygems.org](https://rubygems.org).

### Client Side

The Rails application serves a few different client interfaces:

1. the dashboard at `/`
2. the management interface for organization users at `/manage`
3. the admin interface for internal administrators at `/admin`
4. the desktop and tablet interface at `/app`
5. the smartphone interface at `/smartphone`

The first three interfaces are all generated using server-side code, including Rails views and templates.

The final two interfaces involve a good deal of client-side code, written in [CoffeeScript](http://coffeescript.org/) and compiled to [JavaScript](https://developer.mozilla.org/en-US/docs/JavaScript). Both use a standard JavaScript utility library called [jQuery](http://jquery.com/) as well as:

- The desktop and tablet interface also uses [Backbone.js](http://backbonejs.org/) to structure its code. A list of other JavaScript libraries used is in [app/assets/javascripts/app/libraries.js](https://github.com/s3sol/pedplus/blob/heroku/app/assets/javascripts/app/libraries.js)

- The smartphone interface uses [jQuery Mobile](http://jquerymobile.com/) to structure its code and generate UI widgets and layouts. A list of other JavaScript libraries used is split between  [app/assets/javascripts/smartphone/libraries.js](https://github.com/s3sol/pedplus/blob/heroku/app/assets/javascripts/smartphone/libraries.js) and [app/assets/javascripts/smartphone/libraries-jqm.js](https://github.com/s3sol/pedplus/blob/heroku/app/assets/javascripts/smartphone/libraries-jqm.js)

Note that the smartphone interface is also available as a "wrapper" application for iOS and Android, which requires additional prerequisites and compilation steps. See [the pedcount code repository](https://github.com/s3sol/pedcount) for more information.