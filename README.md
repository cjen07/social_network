# SocialNetwork

To config
  * postgresql in config/dev.exs
  * mailgun in config/config.exs
  * arc in config/config.exs
  * neo4j/bolt in config/config.exs
  
To setup
  
  * run in neo4j: `CREATE (n:Id {name: "post", id: 0}) RETURN n`

To start your Phoenix app:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.create && mix ecto.migrate`
  * Install Node.js dependencies with `npm install`
  * Make sure the neo4j database is up with bolt enabled on port 7687
  * Start Phoenix endpoint with `mix phoenix.server`
  * Now you can visit `localhost:4000` from your browser.

Feature

  * one comment can only be referred to one comment at one time using reply button
  
To be done

  * message notification
  * exception handling
  * private online chat (optional)
