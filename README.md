# SocialNetwork

Remark
  
  * Very welcome to anyone who is willing to try it out and give any suggestions
  * All releases are working well and this branch is still under development

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

  * online notification persistence and online user mark
  * new/delete post/comment/reply/thumb notifications of all pages
  * friend relationship change notification: new follower and following deleted
  * comment or thumb on deleted post, re-delete post/comment and re-thumb notification are settled
  * re-follow and re-unfollow are settled, home, following, follower, follow/unfollow of a deleted user are prevented
  * image upload should be less than 2MB, post and comment should be no more than 500 characters 

Goal in short term
  
  * private chat using phoenix presense: chat button and chat panel
  * gif instuctions in this readme and online example
  
Goal in long term

  * offline notification and chat persistence
  * make it dry, and test it by wallaby
  * fewer limitations and hidden bugs

Limitation

  * one comment can only be referred to one comment at one time using reply button
  * same user same time double comment on same post will resulted in undefined behaviour
  * only one image per post is allowed, audio/video not supported, post re-delivering not supported
  * if A comments on B's post, A does not follow B, and anyone replies A in B's post and then B deletes that post, the notification in A's news page will not disappear, which is what "possibly" means in the notification.
  * if A follows B, and B does not follow A and then A deletes his/her account, the "new follower" notification in B's friend page will not disappear 
  
Bugs
  
  * bolt_sip bug, not knowing exactly how to trigger it again
  * phoenix_timex Timex.from_now() -1 minutes ago 
