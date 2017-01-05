# SocialNetwork

To setup

  * Install phoenix framework and its [components](http://www.phoenixframework.org/docs/installation) including erlang, elixir, phoenix, nodejs and postgresql
  * Download [neo4j (community version)](https://neo4j.com/download/community-edition/) and start the database with `./neo4j-community-a.b.c/bin/neo4j console`
  
To config

  * postgresql in config/dev.exs
  * mailgun in config/config.exs
  * arc in config/config.exs
  * neo4j/bolt in config/config.exs  

To start your Phoenix app:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.create && mix ecto.migrate`
  * Install Node.js dependencies with `npm install`
  * Start Phoenix endpoint with `mix phoenix.server`
  * Now you can visit `localhost:4000` from your browser.

Feature

  * one comment can only be referred to one comment at one time using reply button
  
To be done

  * message notification
  * exception handling
  * private online chat (optional)
