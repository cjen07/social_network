let helper = {

  comment_helper(data, post_id) {
    if (data.error){
      alert(data.error)
      return
    }
    let comments = data.comments
    $("#comment_" + post_id).empty()
    comments.forEach(function (e){
      let $img = $('<img/>', {
          alt: "User Image",
          "class": "img-circle avatar", 
          src: e.url
      })
      let $a = $('<a/>')
                .addClass("pull-left")
                .append($img)
      let $user = $('<h4/>')
                   .addClass("user")
                   .text(e.user.name)
      let $time = $('<h5/>')
                   .addClass("time")
                   .text(e.from_now)
      let $head = $('<div/>')
                   .addClass("comment-heading")
                   .append($user)
                   .append(" ")
                   .append($time)
      if (e.self){
        let $delete = $('<button/>', {
            "class": "btn btn-default btn-comment-delete btn-xs",
            time: e.time,
            id: post_id,
            text: "delete"
        })
        $head.append(" ")
        $head.append($delete)
      }
      else{
        let $reply = $('<button/>', {
            "class": "btn btn-default btn-comment-reply btn-xs",
            email: e.user.email,
            name: e.user.name,
            time: e.time,
            id: post_id,
            text: "reply"
        })
        $head.append(" ")
        $head.append($reply)
      }
      let $text
      if (jQuery.isEmptyObject(e.refer)){
        $text = $('<pre/>').text(e.text) 
      }
      else{
        let $refer = $('<a/>')
                    .addClass("refer")
                    .attr("flag", e.refer.email == e.email)
                    .attr("name", e.refer.name)
                    .attr("email", e.refer.email)
                    .text("@" + e.refer.name)
        $text = $('<pre/>')
                .text(": " + e.text)
                .prepend($refer)
      }       
      let $body = $('<div/>')
                   .addClass("comment-body")
                   .append($head)
                   .append($text)
      $("#comment_" + post_id).append(
        $('<div/>')
          .addClass("comment")
          .append($a)
          .append($body)
      )
    })
  },

  thumb_helper(data, post_id){
    $("#thumb_" + post_id).empty()
    let thumbs = data.thumbs
    if (thumbs.length != 0){
      if (data.has_image){
        $("#thumb_" + post_id).append("<br>")
      }
      $("#thumb_" + post_id).append("<span class='glyphicon glyphicon-heart glyphicon-thumb'></span> ")
      thumbs.forEach(e => {
        if (e.self){
          $("#thumb_" + post_id).append("<a class='btn btn-default btn-xs btn-thumb' email='" + e.email + "' href='/home'>" + e.name + "</a> ")
        }
        else{
          let name = encodeURIComponent(e.name)
          let email = encodeURIComponent(e.email)
          $("#thumb_" + post_id).append("<a class='btn btn-default btn-xs btn-thumb' email='" + e.email + "' href=/hub?user[email]=" + email + "&amp;user[name]=" + name + ">" + e.name + "</a> ")
        }
      })
    }
  }

}
export default helper