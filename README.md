# SocialNetwork

To setup

  * Install phoenix framework and its [components](http://www.phoenixframework.org/docs/installation) including erlang, elixir, phoenix, nodejs and postgresql
  * Download [neo4j (community version)](https://neo4j.com/download/community-edition/) and start the database with `./neo4j-community-a.b.c/bin/neo4j console`
  
To config

  * postgresql: config/dev.exs, set `alter user postgres with password 'postgres';`for first time users in database command line
  * email: config/config.exs, using different adapters see [here](https://github.com/smpallen99/coherence#configuring-the-swoosh-email-adapter), currently using my mailgun sandbox
  * arc: config/config.exs, using cloud storage see [here](https://github.com/stavro/arc), currently using local storage
  * neo4j/bolt: config/config.exs, to reset neo4j password with command line: [here](http://430.io/change-neo4j-default-password-in-command-line/)
  * localhost: config/config.exs, in endpoint configue: `url: [host: "localhost"]`

To start your Phoenix app:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.create && mix ecto.migrate`
  * Install Node.js dependencies with `npm install`
  * Start Phoenix endpoint with `mix phoenix.server`
  * Now you can visit `localhost:4000` from your browser.

Feature

  * one comment can only be referred to one comment at one time using reply button
  * currently all notification are transient (not functioning when offine and will vanish after refresh)
  * post create or delete notification in friends (or strangers) homepage and news page
  * homepage and other-page comment and thumb notification: facebook style
  * comment or thumb on deleted post is prevented, re-delete post and comment are settled
  
To be done

  * other-page's post / reply notification 
  * exception handling
  * notification persistence
  * private chat and verification
  * follow / unfollow in friends homepage
  * new follower notification
  * friend relationship change notification
  * top page button
  * comment and reply user_link 
  
Bug to fix
  
  * large image upload failure and image upload preview cannot be refixed
  * user deleted misbehaviour
  * unclear bolt_sip bug

