import response from "./response"
import lobby from "./lobby"

let self = {

  init(socket, element){ if(!element.length){ return }
    let email = element.attr('email')
    socket.connect()
    let myChannel   = socket.channel("user:" + email)
    myChannel.join()
      .receive("ok", resp => console.log("joined my channel", resp) )
      .receive("error", reason => console.log("join my channel failed", reason) )
    myChannel.on("new_post", response.warning)
    myChannel.on("delete_post", response.warning)
    let me = $(".myChannel")
    if (me.length){
      myChannel.on("new_comment", response.new_home_message)
      myChannel.on("delete_comment", response.delete_home_message)
      myChannel.on("new_thumb", response.new_home_message)
      myChannel.on("delete_thumb", response.delete_home_message)

      if (sessionStorage.getItem("home-flag") == "true") {
        let n = sessionStorage.getItem("home-data")
        let m = $.parseJSON(n)
        response.put_home_message(m)
      }
    }
    else{
      myChannel.on("new_comment", response.new_home_message_delay)
      myChannel.on("delete_comment", response.delete_home_message_delay)
      myChannel.on("new_thumb", response.new_home_message_delay)
      myChannel.on("delete_thumb", response.delete_home_message_delay)

      if (sessionStorage.getItem("home-flag") == "true") {
        let n = sessionStorage.getItem("home-data")
        let m = $.parseJSON(n)
        response.pick_home_message(m)
      }
    }

    lobby.init(socket, $(".lobbyChannel"))

    $.get("/api/friends",
      function (data){
        let friends = data.friends
        let user = $(".userChannel")
        let users = $(".usersChannel")
        let friend = $(".friendChannel")
        let get_friends = e => {
          let email = e.email
          let name = e.name
          let friendChannel = socket.channel("user:" + email)
          friendChannel.join()
            .receive("ok", resp => console.log("joined " + name + " channel", resp) )
            .receive("error", reason => console.log("join " + name + " channel failed", reason) )
          return friendChannel
        }
        if (!users.length){

          if (user.length){
            let email = user.attr('email')
            let userChannel   = socket.channel("user:" + email)
            if (!friends.find(e => e.email == email)){
              userChannel.join()
                .receive("ok", resp => console.log("joined a stranger channel", resp) )
                .receive("error", reason => console.log("join a stranger channel failed", reason) )
            }
            userChannel.on("new_post", response.new_post)
            userChannel.on("delete_post", response.delete_post)
            myChannel.on("new_reply", e => response.new_reply(e, email, friends))
            myChannel.on("delete_reply", e => response.delete_reply(e, email, friends))
            myChannel.on("new_reply", e => response.new_reply_delay_onsite(e, email))
            myChannel.on("delete_reply", e => response.delete_reply_delay_onsite(e, email))
            response.pick_news_message(email)
            if (sessionStorage.getItem("news-flag") == "true") {
              let n = sessionStorage.getItem("news-data")
              let m = $.parseJSON(n)
              response.put_news_message(m, email, friends)
            }
          }
          else{
            myChannel.on("new_reply", response.new_reply_delay)
            myChannel.on("delete_reply", response.delete_reply_delay)
            response.pick_news_message("")
          }

          friends.forEach(e => {
            let friendChannel = get_friends(e)
            if (user.length && e.email == user.attr('email')){return}
            if (!friend.length) {friendChannel.on("delete_user", response.delete_user_delay)} 
            else {friendChannel.on("delete_user", response.delete_user)}
            friendChannel.on("new_post", response.new_post_delay)
            friendChannel.on("delete_post", response.delete_post_delay)
          })
        }
        else{
          myChannel.on("new_reply", e => response.new_reply(e, "", friends))
          myChannel.on("delete_reply", e => response.delete_reply(e, "", friends))

          sessionStorage.setItem("post-flag", "false")
          if (sessionStorage.getItem("news-flag") == "true") {
            let n = sessionStorage.getItem("news-data")
            let m = $.parseJSON(n)
            response.put_news_message(m, "", friends)
          }

          friends.forEach(e => {
            let friendChannel = get_friends(e)
            friendChannel.on("new_post", response.new_post)
            friendChannel.on("delete_post", response.delete_post)
            friendChannel.on("delete_user", response.delete_user_delay)
          })
        }


        if (friend.length){
          if (sessionStorage.getItem("friend-flag") == "true") {
            let n = sessionStorage.getItem("friend-data")
            let m = $.parseJSON(n)
            response.put_friend_message(m)
            sessionStorage.setItem("friend-flag", "false")
          }
          myChannel.on("new_follower", response.new_follower)
          myChannel.on("delete_follower", response.delete_follower)
        }
        else{
          myChannel.on("new_follower", response.new_follower_delay)
          myChannel.on("delete_follower", response.delete_follower_delay)
        }
      }, "json")
    
  }
}
export default self