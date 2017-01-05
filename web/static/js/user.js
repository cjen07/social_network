let user = {

  init(socket, element){ if(!element.length){ return }
    let email = element.attr('email')
    socket.connect()
    let userChannel   = socket.channel("user:" + email)
    userChannel.join()
      .receive("ok", resp => console.log("joined user channel", resp) )
      .receive("error", reason => console.log("join user channel failed", reason) ) 
  }
}
export default user