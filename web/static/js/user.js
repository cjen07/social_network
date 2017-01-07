import response from "./response"

let user = {

  init(socket, element){ if(!element.length){ return }
    let email = element.attr('email')
    let userChannel   = socket.channel("user:" + email)
    userChannel.on("new_post", response.new_post)
    userChannel.on("delete_post", response.delete_post)
  }
}
export default user