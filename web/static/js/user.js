let user = {

  init(socket, element){ if(!element.length){ return }
    let email = element.attr('email')
    socket.connect()
    let userChannel   = socket.channel("user:" + email)

    userChannel.on("new_post", payload => {
      let count = Number.parseInt($(".alert-info").attr("count"))
      if (count){
        count += 1
        $(".alert-info").text("there are " + count + " new posts")
          .attr("count", count)
          .css('cursor', 'pointer')
          .click( _ => location.reload() )
      }
      else{
        $(".alert-info").text("there is a new post")
          .attr("count", 1)
          .css('cursor', 'pointer')
          .click( _ => location.reload() )
      }   
    })

    userChannel.on("delete_post", payload => {
      let id = payload.post_id
      if (!$("#" + id).length){
        let count = Number.parseInt($(".alert-info").attr("count")) - 1
        if (count == 0){
          $(".alert-info").empty().attr("count", "")
        }
        else if(count != 1){
          $(".alert-info").text("there are " + count + " new posts")
            .attr("count", count)
            .css('cursor', 'pointer')
            .click( _ => location.reload() )
        }
        else{
          $(".alert-info").text("there is a new post")
            .attr("count", 1)
            .css('cursor', 'pointer')
            .click( _ => location.reload() )
        }
      }
      else{
        let count = Number.parseInt($(".alert-danger").attr("count"))
        if (count){
          count += 1
          $(".alert-danger").text("there are " + count + " deleted posts")
            .attr("count", count)
            .css('cursor', 'pointer')
            .click( _ => location.reload() )
        }
        else{
          $(".alert-danger").text("there is a deleted post")
            .attr("count", 1)
            .css('cursor', 'pointer')
            .click( _ => location.reload() )
        }
      }           
    })

    userChannel.join()
      .receive("ok", resp => console.log("joined user channel", resp) )
      .receive("error", reason => console.log("join user channel failed", reason) ) 
  }
}
export default user