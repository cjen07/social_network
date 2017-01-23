defmodule SocialNetwork.EjabberdController do
  use SocialNetwork.Web, :controller
 
  # This is used to import the jid record structure from ejabberd:
  require Record
  Record.defrecord :jid, Record.extract(:jid, from: "deps/ejabberd/include/jlib.hrl")
    
  # plug :action
  
  def index(conn, _params) do
    # get online jid, parse and extract the user part.
    online_users = :ejabberd_sm.connected_users
                      |> Enum.map &(jid(:jlib.string_to_jid(&1), :user))    
    render conn, "index.html", users: online_users
  end
end