# SocialNetwork

Remark
  
  * Very welcome to anyone who is willing to try it out and give any suggestions
  * All releases are working well and this respository is still under rapid development

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
  * new/delete post/comment/reply/thumb notifications of homepage and news page
  * comment or thumb on deleted post, re-delete post/comment and re-thumb notification are settled
  * image upload should be less than 2MB, post and comment should be no more than 500 characters
  
To be done
  
  * make it dry in controllers and js, move js in vendor to ES6, and test it by wallaby
  * friends homepage notification integration with news page
  * friend relationship change notification: new follower and following deleted
  * rewrite back button in friends page to be more concise
  * gif instuctions in this readme and online example
  * offline notification persistence
  * private chat and verification

Limitation

  * one comment can only be referred to one comment at one time using reply button
  * if you want to be notified when you are replied, you have to follow the post owner
  * same user same time double comment on same post will resulted in undefined behaviour
  * only one image per post is allowed, audio/video not supported, post re-delivering not supported
  
Bugs
  
  * bolt_sip bug, not knowing exactly how to trigger it again
  * phoenix_timex Timex.from_now() -1 minutes ago 
