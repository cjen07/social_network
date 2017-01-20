import helper from "./helper"

let response = {

  warning(_payload){
    sessionStorage.setItem("warning", "true");
    location.reload()
  },

  put_news_message(m, email0, friends){
    let list = $(".message-notification-list")
    for (let post_id in m){
      let cs = m[post_id]
      if (cs.length > 0){
        let that_email = cs[0].source
        if ((email0 == "" && friends.find(e => e.email == that_email)) || email0 == that_email){
          let reply = 0
        
          cs.forEach(e => {
            // remove new replies that is loaded for integrity
            let email = e.email
            ++reply
            let time = e.time
            let $reply = $("button[time='" + time + "'][email='" + email + "'][id='" + post_id + "']").closest('.comment')
            $reply.remove()
          })

          let post = select_helper3(post_id, reply)
          list.append(post)
        }
        else{
          let reply = cs.length
          let post = select_helper4(post_id, reply, that_email)
          list.append(post)
        }  
      }
    }
  },

  pick_news_message(email){
    let news = $(".nav-news")

    if (sessionStorage.getItem("news-flag") == "true"){
      let n = sessionStorage.getItem("news-data")
      let m = $.parseJSON(n)
      let reply = 0
      let flag = false
      for (let post_id in m){
        let cs = m[post_id]
        if (cs.length > 0){
          if (cs[0].source != email){
            reply += cs.length
          }
        }
      }
      let counter = $('<span/>').addClass("button-badge")
      if (reply != 0){
        counter.attr("reply", reply).text(reply)
        flag = true
      }

      if (sessionStorage.getItem("post-flag") == "true"){
        let n = sessionStorage.getItem("post-data")
        let m = $.parseJSON(n)
        let post = m.length
        counter.attr("post", post)
        if (!flag) {counter.text("$")}
        flag = true
      }

      if (flag){news.append(counter)}
    }
    else if (sessionStorage.getItem("post-flag") == "true"){
      let n = sessionStorage.getItem("post-data")
      let m = $.parseJSON(n)
      let post = m.length
      let counter = $('<span/>')
                  .addClass("button-badge")
                  .attr("post", post)
                  .text("$")
      news.append(counter)
    }

  },

  new_post(_payload){
    let count = get_count("info")
    select_helper1("info", "new", ++count)
  },

  delete_post(payload){
    let post_id = payload.post_id
    if (!$("#" + post_id).length){
      let count = get_count("info")
      select_helper1("info", "new", --count)
    }
    else{
      let count = get_count("danger")
      select_helper1("danger", "deleted", ++count)
    }
  },

  new_post_delay(payload){
    let id = payload.post_id
    let news = $(".nav-news")
    let counter = news.find(".button-badge")
    if (sessionStorage.getItem("post-flag") == "true"){
      // add the data not show the text
      let n = sessionStorage.getItem("post-data")
      let m = $.parseJSON(n)
      m.push(id)
      sessionStorage.setItem("post-data", JSON.stringify(m))
      let post = Number.parseInt(counter.attr("post")) + 1
      counter.attr("post", post)
    }
    else{
      // create the data
      sessionStorage.setItem("post-flag", "true")
      let m = [id]
      sessionStorage.setItem("post-data", JSON.stringify(m))
      if (sessionStorage.getItem("news-flag") != "true"){
        // add the counter and show the text
        counter = $('<span/>')
                    .addClass("button-badge")
                    .attr("post", 1)
                    .text("$")
        news.append(counter)
      }
      else{
        counter.attr("post", 1)
      }
    }
  },

  delete_post_delay(payload){
    let id = payload.post_id
    let news = $(".nav-news")
    let counter = news.find(".button-badge")
    if (sessionStorage.getItem("news-flag") == "true"){
      // clear related replies
      let n = sessionStorage.getItem("news-data")
      let m = $.parseJSON(n)
      if (id in m){
        let l = (m[id]).length
        if (l > 0){
          m[id] = []
          sessionStorage.setItem("news-data", JSON.stringify(m))
          let reply = Number.parseInt(counter.attr("reply")) - l
          counter.attr("reply", reply)
          if (reply == 0){
            sessionStorage.setItem("news-flag", "false")
            if (sessionStorage.getItem("post-flag") == "true"){
              counter.text("$")
            }
            else{
              counter.remove()
            }
          }
        }

      }
    }

    if (sessionStorage.getItem("post-flag") == "true"){
      let n = sessionStorage.getItem("post-data")
      let m = $.parseJSON(n)
      // clear same post
      let index = m.findIndex(e => e == id)
      if (index > -1) {
        m.splice(index, 1)
        sessionStorage.setItem("post-data", JSON.stringify(m))
        if (m.length > 0){
          let post = Number.parseInt(counter.attr("post")) - 1
          counter.attr("post", post)
        }
        else{
          sessionStorage.setItem("post-flag", "false")
          if (sessionStorage.getItem("news-flag") != "true"){
            counter.remove()
          }
        }
      }
    }
  },

  new_reply(payload, email0, friends){
    let post_id = payload.post_id
    let email = payload.email
    let that_email = payload.source
    let list = $(".message-notification-list")
    let post = list.find("#" + post_id)
    if (sessionStorage.getItem("news-flag") != "true"){
      sessionStorage.setItem("news-flag", "true")
      sessionStorage.setItem("news-data", JSON.stringify({}))
    }
    let n = sessionStorage.getItem("news-data")
    let m = $.parseJSON(n)
    let id = post_id
    if (!post.length){
      m[id] = [{email: email, source: that_email, time: payload.time}]
      if (friends.find(e => e.email == that_email) || email0 == that_email){
        post = select_helper3(post_id, 1)
        list.append(post)
      }
      else{
        post = select_helper4(post_id, 1, that_email)
        list.append(post)
      } 
    }
    else{
      let reply = Number.parseInt(post.attr("reply")) + 1
      let cs = m[id]
      let c = {email: email, source: that_email, time: payload.time}
      cs.push(c)
      m[id] = cs
      if (friends.find(e => e.email == that_email) || email0 == that_email){
        post.attr("reply", reply)
            .text("there are " + reply + " new replies in a post")
      }
      else{
        post.attr("reply", reply)
            .text("possibly " + reply + " new replies in a stranger's homepage")
      }
        
    }
    sessionStorage.setItem("news-data", JSON.stringify(m))
  },

  delete_reply(payload, email0, friends){
    let id = payload.post_id
    let email = payload.email
    let that_email = payload.source
    let list = $(".message-notification-list")
    let post = list.find("#" + id)
    if (!post.length) {return}
    let n = sessionStorage.getItem("news-data")
    let m = $.parseJSON(n)

    if (id in m){
      let cs = m[id]
      let c = {email: email, source: that_email, time: payload.time}
      let index = cs
      .map(e => JSON.stringify(e))
      .indexOf(JSON.stringify(c))
      if (index > -1) {
        cs.splice(index, 1)
        m[id] = cs
        sessionStorage.setItem("news-data", JSON.stringify(m))
        let reply = Number.parseInt(post.attr("reply")) - 1
        if (reply == 0) {
          post.remove()
          let flag = true
          for (let key in m){
            if((m[key]).length > 0){
              flag = false
              break
            }
          }
          if (flag){
            sessionStorage.setItem("news-flag", "false")
          }
        }
        else{
          if (friends.find(e => e.email == that_email) || email0 == that_email){
            let text = (reply == 1) ? "there is a new reply" : "there are " + reply + " new replies"
            post.attr("reply", reply)
              .text(text + " in a post")
          }
          else{
            let text = (reply == 1) ? "possibly a new reply" : "possibly " + reply + " new replies"
            post.attr("reply", reply)
              .text(text + " in a stranger's homepage")
          }
        }
      }
    }
  },

  new_reply_delay_onsite(payload, email){
    if (payload.email == email){return}
    new_reply_delay(payload)
  },

  new_reply_delay(payload){
    let id = payload.post_id
    let email = payload.email
    let news = $(".nav-news")
    let counter = news.find(".button-badge")
    if (sessionStorage.getItem("news-flag") != "true"){
      sessionStorage.setItem("news-flag", "true")
      let m = {}
      m[id] = [{email: email, source: payload.source, time: payload.time}]
      sessionStorage.setItem("news-data", JSON.stringify(m))
      if (sessionStorage.getItem("post-flag") == "true"){
        counter.attr("reply", 1).text(1)
      }
      else{
        counter = $('<span/>')
                    .addClass("button-badge")
                    .attr("reply", 1)
                    .text(1)
        news.append(counter)
      }
    }
    else{
      let reply = Number.parseInt(counter.attr("reply")) + 1
      counter
        .attr("reply", reply)
        .text(reply)
      let n = sessionStorage.getItem("news-data")
      let m = $.parseJSON(n)
      if (id in m){
        let cs = m[id]
        let c = {email: email, source: payload.source, time: payload.time}
        cs.push(c)
        m[id] = cs
        sessionStorage.setItem("news-data", JSON.stringify(m))
      }
      else{
        m[id] = [{email: email, source: payload.source, time: payload.time}]
        sessionStorage.setItem("news-data", JSON.stringify(m))
      }
    }
  },

  delete_reply_delay_onsite(payload, email){
    if (payload.email == email){return}
    delete_reply_delay(payload)
  },

  delete_reply_delay(payload){
    let id = payload.post_id
    let email = payload.email
    let news = $(".nav-news")
    let counter = news.find(".button-badge")
    if (sessionStorage.getItem("news-flag") != "true"){return}

    let n = sessionStorage.getItem("news-data")
    let m = $.parseJSON(n)
    if (id in m){
      let cs = m[id]
      let c = {email: email, source: payload.source, time: payload.time}
      let index = cs
      .map(e => JSON.stringify(e))
      .indexOf(JSON.stringify(c))
      if (index > -1) {
        cs.splice(index, 1)
        m[id] = cs
        sessionStorage.setItem("news-data", JSON.stringify(m))
        let reply = Number.parseInt(counter.attr("reply")) - 1
        if (reply == 0) {
          sessionStorage.setItem("news-flag", "false")
          if (sessionStorage.getItem("post-flag") == "true"){
            counter.text("$")
          }
          else{
            counter.remove()
          }
        }
        else{
          counter
            .attr("reply", reply)
            .text(reply)
        }
      }
    }
  },

  put_home_message(m){
    let list = $(".message-notification-list")
    for (let post_id in m){
      let cs = m[post_id]
      if (cs.length > 0){

        let comment = 0
        let thumb = 0
      
        cs.forEach(e => {
          // remove new comments that is loaded for integrity
          let type = e.type 
          let email = e.email
          if (type == "comment"){
            ++comment
            let time = e.time
            let $comment = $("button[time='" + time + "'][email='" + email + "'][id='" + post_id + "']").closest('.comment')
            $comment.remove()
          }
          else{
            ++thumb
            let $thumb = $("#thumb_" + post_id).find(".btn-thumb[email='" + email + "']")
            $thumb.remove()
            if (!$("#thumb_" + post_id).find(".btn-thumb").length) {$("#thumb_" + post_id).empty()}
          } 
        })

        let post = select_helper2(post_id, comment, thumb)
        list.append(post)
      }
    }
  },

  pick_home_message(m){
    let home = $(".nav-home")

    let comment = 0
    let thumb = 0
    for (let post_id in m){
      let cs = m[post_id]
      cs.forEach(e => {
        let type = e.type
        if (type == "comment"){++comment} else {++thumb}
      })
    }
    let total = comment + thumb

    let counter = $('<span/>')
                .addClass("button-badge")
                .attr("comment", comment)
                .attr("thumb", thumb)
                .text(total)
    home.append(counter)

  },

  new_home_message(payload){
    let post_id = payload.post_id
    let email = payload.email
    let type = payload.type
    let list = $(".message-notification-list")
    let post = list.find("#" + post_id)
    if (sessionStorage.getItem("home-flag") != "true"){
      sessionStorage.setItem("home-flag", "true")
      sessionStorage.setItem("home-data", JSON.stringify({}))
    }
    let n = sessionStorage.getItem("home-data")
    let m = $.parseJSON(n)
    let id = post_id
    if (!post.length){
      let comment = 0
      let thumb = 0
      if (type == "comment") {++comment} else {++thumb}
      m[id] = (type == "comment") ? [{email: email, type: type, time: payload.time}] : [{email: email, type: type}]
      post = select_helper2(post_id, comment, thumb)
      list.append(post)
    }
    else{
      let comment = Number.parseInt(post.attr("comment"))
      let thumb = Number.parseInt(post.attr("thumb"))
      if (type == "comment") {++comment} else {++thumb}
      let cs = m[id]
      let c = (type == "comment") ? {email: email, type: type, time: payload.time} : {email: email, type: type}
      cs.push(c)
      m[id] = cs
      let text = gen_text(comment, thumb)
      post.attr("comment", comment)
          .attr("thumb", thumb)
          .text(text + " in a post")
    }
    sessionStorage.setItem("home-data", JSON.stringify(m))
  },

  delete_home_message(payload){
    let id = payload.post_id
    let email = payload.email
    let type = payload.type
    let list = $(".message-notification-list")
    let post = list.find("#" + id)
    if (!post.length) {return}

    let n = sessionStorage.getItem("home-data")
    let m = $.parseJSON(n)

    if (id in m){
      let cs = m[id]
      let c = (type == "comment") ? {email: email, type: type, time: payload.time} : {email: email, type: type}
      let index = cs
      .map(e => JSON.stringify(e))
      .indexOf(JSON.stringify(c))
      if (index > -1) {
        cs.splice(index, 1)
        m[id] = cs
        sessionStorage.setItem("home-data", JSON.stringify(m))
        let comment = Number.parseInt(post.attr("comment"))
        let thumb = Number.parseInt(post.attr("thumb"))
        if (type == "comment") {--comment} else {--thumb}
        let total = comment + thumb
        if (total == 0) {
          post.remove()
          let flag = true
          for (let key in m){
            if((m[key]).length > 0){
              flag = false
              break
            }
          }
          if (flag){
            sessionStorage.setItem("home-flag", "false")
          }
        }
        else{
          let text = gen_text(comment, thumb)
          post.attr("comment", comment)
            .attr("thumb", thumb)
            .text(text + " in a post")
        }
      }
    }
  },

  new_home_message_delay(payload){
    let id = payload.post_id
    let email = payload.email
    let type = payload.type
    let home = $(".nav-home")
    let counter = home.find(".button-badge")
    if (!counter.length){
      let comment  = 0
      let thumb = 0
      if (type == "comment") {++comment} else {++thumb}
      counter = $('<span/>')
                  .addClass("button-badge")
                  .attr("comment", comment)
                  .attr("thumb", thumb)
                  .text(1)
      home.append(counter)
      sessionStorage.setItem("home-flag", "true")
      let m = {}
      m[id] = (type == "comment") ? [{email: email, type: type, time: payload.time}] : [{email: email, type: type}]
      sessionStorage.setItem("home-data", JSON.stringify(m))
    }
    else{
      let comment = Number.parseInt(counter.attr("comment"))
      let thumb = Number.parseInt(counter.attr("thumb"))
      if (type == "comment") {++comment} else {++thumb}
      let total = comment + thumb
      counter
        .attr("comment", comment)
        .attr("thumb", thumb)
        .text(total)
      let n = sessionStorage.getItem("home-data")
      let m = $.parseJSON(n)
      if (id in m){
        let cs = m[id]
        let c = (type == "comment") ? {email: email, type: type, time: payload.time} : {email: email, type: type}
        cs.push(c)
        m[id] = cs
        sessionStorage.setItem("home-data", JSON.stringify(m))
      }
      else{
        m[id] = (type == "comment") ? [{email: email, type: type, time: payload.time}] : [{email: email, type: type}]
        sessionStorage.setItem("home-data", JSON.stringify(m))
      }
    }
  },

  delete_home_message_delay(payload){
    let id = payload.post_id
    let email = payload.email
    let type = payload.type
    let time = payload.time
    let home = $(".nav-home")
    let counter = home.find(".button-badge")
    if (!counter.length){return}

    let n = sessionStorage.getItem("home-data")
    let m = $.parseJSON(n)
    if (id in m){
      let cs = m[id]
      let c = (type == "comment") ? {email: email, type: type, time: payload.time} : {email: email, type: type}
      let index = cs
      .map(e => JSON.stringify(e))
      .indexOf(JSON.stringify(c))
      if (index > -1) {
        cs.splice(index, 1)
        m[id] = cs
        sessionStorage.setItem("home-data", JSON.stringify(m))
        let comment = Number.parseInt(counter.attr("comment"))
        let thumb = Number.parseInt(counter.attr("thumb"))
        if (type == "comment") {--comment} else {--thumb}
        let total = comment + thumb
        if (total == 0) {
          counter.remove()
          sessionStorage.setItem("home-flag", "false")
        }
        else{
          counter
            .attr("comment", comment)
            .attr("thumb", thumb)
            .text(total)
        }
      }
    }
  }

}

function get_count(name){
  return Number.parseInt($(".alert-" + name).attr("count"))
}

function select_helper1(name, type, count){
  if (count == 0){
    $(".message-" + name).empty().attr("count", count)
    return
  }
  let text = (count == 1) ? "there is a " + type + " post" : "there are " + count + " " + type + " posts"
  $(".message-" + name).text(text)
    .attr("count", count)
    .css('cursor', 'pointer')
    .click( _ => location.reload() )
}

function gen_text(comment, thumb){
  let total = comment + thumb
  let text1 = (total == 1) ? "there is " : "there are "
  let text2 = ""
  let text3 = (comment != 0 && thumb != 0) ? "and " : ""
  let text4 = ""
  if (comment == 1){
    text2 = "a new comment "
  }
  else if (comment > 1){
    text2 = comment + " new comments "
  }
  if (thumb == 1){
    text4 = "a new like "
  }
  else if (thumb > 1){
    text4 = thumb + " new likes "
  }
  let text = text1 + text2 + text3 + text4
  return text
}

function select_helper2(post_id, comment, thumb){
  let text = gen_text(comment, thumb)
  let post = 
  $('<li/>')
    .addClass("alert alert-info")
    .attr("role", "alert")
    .attr("comment", comment)
    .attr("thumb", thumb)
    .attr("id", post_id)
    .text(text + " in a post")
    .css('cursor', 'pointer')
    .click( _ => {
      $.get("/api/message/home?post_id=" + post_id,
        data => {
          if (data.error){
            alert(data.error)
            return
          }
          if (sessionStorage.getItem("home-flag") == "true") {
            let n = sessionStorage.getItem("home-data")
            let m = $.parseJSON(n)
            let id = post_id
            if (id in m){
              m[id] = []
              let flag = true
              for (let key in m){
                if((m[key]).length > 0){
                  flag = false
                  break
                }
              }
              if (flag){
                sessionStorage.setItem("home-flag", "false")
              }
              else{
                sessionStorage.setItem("home-data", JSON.stringify(m))
              }
            }
          }
          helper.comment_helper(data, post_id)
          helper.thumb_helper(data, post_id)
        }, "json")
      $(".panel[id='" + post_id + "']").scrollView()
      post.remove()
    })
  return post
}

function select_helper3(post_id, reply){
  let text = (reply == 1) ? "there is a new reply" : "there are " + reply + " new replies"
  let post = 
  $('<li/>')
    .addClass("alert alert-info")
    .attr("role", "alert")
    .attr("reply", reply)
    .attr("id", post_id)
    .text(text + " in a post")
    .css('cursor', 'pointer')
    .click( _ => {
      $.get("/api/message/home?post_id=" + post_id,
        data => {
          if (data.error){
            alert(data.error)
            return
          }
          if (sessionStorage.getItem("news-flag") == "true") {
            let n = sessionStorage.getItem("news-data")
            let m = $.parseJSON(n)
            let id = post_id
            if (id in m){
              m[id] = []
              let flag = true
              for (let key in m){
                if((m[key]).length > 0){
                  flag = false
                  break
                }
              }
              if (flag){
                sessionStorage.setItem("news-flag", "false")
              }
              else{
                sessionStorage.setItem("news-data", JSON.stringify(m))
              }
            }
          }
          helper.comment_helper(data, post_id)
          helper.thumb_helper(data, post_id)
        }, "json")
      $(".panel[id='" + post_id + "']").scrollView()
      post.remove()
    })
  return post
}

function select_helper4(post_id, reply, email){
  let text = (reply == 1) ? "possibly a new reply" : "possibly " + reply + " new replies"
  let post = 
  $('<li/>')
    .addClass("alert alert-info")
    .attr("role", "alert")
    .attr("reply", reply)
    .attr("id", post_id)
    .text(text + " in a stranger's homepage")
    .css('cursor', 'pointer')
    .click( _ => {
      let url = "/hub?user[email]=" + encodeURIComponent(email)
      window.location.href = url
    })
  return post
}

$.fn.scrollView = function () {
    return this.each(function () {
        $('html, body').animate({
            scrollTop: $(this).offset().top
        }, 1000)
    })
}

export default response