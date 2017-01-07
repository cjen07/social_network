import response from "./response"

let self = {

  init(socket, element){ if(!element.length){ return }
    let email = element.attr('email')
    socket.connect()
    let myChannel   = socket.channel("user:" + email)
    myChannel.join()
      .receive("ok", resp => console.log("joined my channel", resp) )
      .receive("error", reason => console.log("join my channel failed", reason) )

    $.get("/api/friends",
      function (data){
        let friends = data.friends
        let element = $(".usersChannel")
        let get_friends = e => {
          let email = e.email
          let name = e.name
          let friendChannel = socket.channel("user:" + email)
          friendChannel.join()
            .receive("ok", resp => console.log("joined " + name + " channel", resp) )
            .receive("error", reason => console.log("join " + name + " channel failed", reason) )
          return friendChannel
        }
        if (!element.length){
          friends.forEach(get_friends)
        }
        else{
          friends.forEach(e => {
            let friendChannel = get_friends(e)
            friendChannel.on("new_post", response.new_post)
            friendChannel.on("delete_post", response.delete_post)
          })
        }
      }, "json")
  }
}
export default self