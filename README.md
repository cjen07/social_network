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

  * online notification persistence
  * one comment can only be referred to one comment at one time using reply button
  * new/delete post/comment/reply/thumb notifications of homepage and news page
  * comment or thumb on deleted post, re-delete post/comment and re-thumb notification are settled
  * if you want to be notified when you are replied, follow the post owner
  
To be done
  
  * exception handling: delete user
  * top page button
  * basic friends page notification: new follower, post/comment/reply integrity with news notification 
  * offline notification persistence
  * private chat and verification
  * friend relationship change notification
  * follow / unfollow in friends homepage
  * comment and reply user_link 
  
Bug to fix
  
  * large image upload failure and image upload preview cannot be refixed
  * unclear bolt_sip bug

