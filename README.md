# loltistics

Player tracking for League of Legends (early precedessor to sites like [LoLKing](http://www.lolking.net/)).

_This project is now dead and the code seen here is provided for posterity. If you can get this running, please get in touch._

Website:

- ~~https://loltistics.herokuapp.com/~~ (Dead)
- Archive: http://web.archive.org/web/20101017185831/http://loltistics.heroku.com:80/

## Features

- Uploading of League of Legends game logs via the website
- Tracking Player and Match information

## About

This was fairly interesting and fun at the time because there was no way to view your player and match info offline.
When I wrote this, some log uploaders were being created by nothing existed (yet).

This is a basic Ruby web app built on Sinatra that uses MongoDB for persistence.
MongoDB was a natural choice because the League of Legends log file schema was constantly changing.
I wrote a simple recursive-descent logfile parser to parse the logs.
