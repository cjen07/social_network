let self = {

  init(socket, element){ if(!element.length){ return }
    let email = element.attr('email')
    socket.connect()
    let myChannel   = socket.channel("user:" + email)
    myChannel.join()
      .receive("ok", resp => console.log("joined my channel", resp) )
      .receive("error", reason => console.log("join my channel failed", reason) ) 
  }
}
export default self