$(function () {

  if ( sessionStorage.getItem("warning") == "true" ) {
    $(".alert-warning").text("updated by another endpoint");
    sessionStorage.setItem("warning", "false");
  }

  var offset = 10;
  var duration = 300;
  
  if ($(this).scrollTop() < offset) {
    $('.back-to-top').hide();
  }

  $(window).scroll(function() {
    if ($(this).scrollTop() > offset) {
      $('.back-to-top').fadeIn(duration);
    } else {
      $('.back-to-top').fadeOut(duration);
    }
  });

  $('.back-to-top').click(function(event) {
    event.preventDefault();  
    $('html, body').animate({scrollTop: 0}, "slow");
    return false;
  });

  $('.btn-heart').click(function(){
    $(this).blur();
    var post_id = $(this).attr('id');
    var span_id = $(this).find(".glyphicon").attr('id');
    $.get("/api/thumb?post_id=" + post_id + "&span_id=" + span_id,
      function (data){
        if (data.error){
          alert(data.error);
          return;
        }
        $(".btn-heart[id='" + post_id + "']").empty();
        if (data.thumb) {
          $(".btn-heart[id='" + post_id + "']").append("<span id='0' class='glyphicon glyphicon-heart glyphicon-btn'></span>");
        }
        else {
          $(".btn-heart[id='" + post_id + "']").append("<span id='1' class='glyphicon glyphicon-heart-empty glyphicon-btn'></span>");
        }

        $("#thumb_" + post_id).empty();
        var thumbs = data.thumbs
        if (thumbs.length != 0){
          if (data.has_image){
            $("#thumb_" + post_id).append("<br>");
          }
          $("#thumb_" + post_id).append("<span class='glyphicon glyphicon-heart glyphicon-thumb'></span> ");
          thumbs.forEach(function (e){
            if (e.self){
              $("#thumb_" + post_id).append("<a class='btn btn-default btn-xs btn-thumb' email='" + e.email + "' href='/home'>" + e.name + "</a> ");
            }
            else{
              var name = encodeURIComponent(e.name);
              var email = encodeURIComponent(e.email);
              $("#thumb_" + post_id).append("<a class='btn btn-default btn-xs btn-thumb' email='" + e.email + "' href=/hub?user[email]=" + email + "&amp;user[name]=" + name + ">" + e.name + "</a> ");
            }
          });
        }

      }, "json");
  });
  $('.btn-comment-create').click(function(){
    var $panel = $(this).closest('.panel-google-plus');
    var $comment = $panel.find('.panel-google-plus-comment');
    var post_id = $(this).attr('id');
    var email = $(this).attr('email');
    var text = $comment.find('textarea').val();
    $.get("/api/comment/create?post_id=" + post_id 
      + "&comment=" + encodeURIComponent(text)
      + "&email=" + encodeURIComponent(email),
      function (data){
        if (data.error){
          alert(data.error);
          return;
        }
        var comments = data.comments;
        $("#comment_" + post_id).empty();
        comments.forEach(function (e){
          var $img = $('<img/>', {
              alt: "User Image",
              "class": "img-circle avatar", 
              src: e.url
          });
          var $a = $('<a/>')
                    .addClass("pull-left")
                    .append($img);
          var $user = $('<h4/>')
                       .addClass("user")
                       .text(e.user.name);
          var $time = $('<h5/>')
                       .addClass("time")
                       .text(e.from_now);
          var $head = $('<div/>')
                       .addClass("comment-heading")
                       .append($user)
                       .append(" ")
                       .append($time);
          if (e.self){
            var $delete = $('<button/>', {
                "class": "btn btn-default btn-comment-delete btn-xs",
                time: e.time,
                id: post_id,
                text: "delete"
            });
            $head.append(" ");
            $head.append($delete);
          }
          else{
            var $reply = $('<button/>', {
                "class": "btn btn-default btn-comment-reply btn-xs",
                email: e.user.email,
                name: e.user.name,
                time: e.time,
                id: post_id,
                text: "reply"
            });
            $head.append(" ");
            $head.append($reply);
          }
          var $text;
          if (jQuery.isEmptyObject(e.refer)){
            $text = $('<pre/>').text(e.text); 
          }
          else{
            var $refer = $('<a/>')
                        .addClass("refer")
                        .attr("flag", e.refer.email == e.email)
                        .attr("name", e.refer.name)
                        .attr("email", e.refer.email)
                        .text("@" + e.refer.name);
            $text = $('<pre/>')
                    .text(": " + e.text)
                    .prepend($refer);
          }       
          var $body = $('<div/>')
                       .addClass("comment-body")
                       .append($head)
                       .append($text);
          $("#comment_" + post_id).append(
            $('<div/>')
              .addClass("comment")
              .append($a)
              .append($body)
          );
        });
      }, "json");
    $comment.find('button[type="reset"]').click();
  });
  $(".panel-footer").on("click", '.btn-comment-delete', function(){
    var post_id = $(this).attr('id');
    var time = $(this).attr('time');
    $.get("/api/comment/delete?post_id=" + post_id + "&time=" + time,
      function (data){
        if (data.error){
          alert(data.error);
          return;
        }
        var comments = data.comments;
        $("#comment_" + post_id).empty();
        comments.forEach(function (e){
          var $img = $('<img/>', {
              alt: "User Image",
              "class": "img-circle avatar", 
              src: e.url
          });
          var $a = $('<a/>')
                    .addClass("pull-left")
                    .append($img);
          var $user = $('<h4/>')
                       .addClass("user")
                       .text(e.user.name);
          var $time = $('<h5/>')
                       .addClass("time")
                       .text(e.from_now);
          var $head = $('<div/>')
                       .addClass("comment-heading")
                       .append($user)
                       .append(" ")
                       .append($time);
          if (e.self){
            var $delete = $('<button/>', {
                "class": "btn btn-default btn-comment-delete btn-xs",
                time: e.time,
                id: post_id,
                text: "delete"
            });
            $head.append(" ");
            $head.append($delete);
          }
          else{
            var $reply = $('<button/>', {
                "class": "btn btn-default btn-comment-reply btn-xs",
                email: e.user.email,
                name: e.user.name,
                time: e.time,
                id: post_id,
                text: "reply"
            });
            $head.append(" ");
            $head.append($reply);
          }
          var $text;
          if (jQuery.isEmptyObject(e.refer)){
            $text = $('<pre/>').text(e.text); 
          }
          else{
            var $refer = $('<a/>')
                        .addClass("refer")
                        .attr("flag", e.refer.email == e.email)
                        .attr("name", e.refer.name)
                        .attr("email", e.refer.email)
                        .text("@" + e.refer.name);
            $text = $('<pre/>')
                    .text(": " + e.text)
                    .prepend($refer);
          }       
          var $body = $('<div/>')
                       .addClass("comment-body")
                       .append($head)
                       .append($text);
          $("#comment_" + post_id).append(
            $('<div/>')
              .addClass("comment")
              .append($a)
              .append($body)
          );
        });
      }, "json");
  });

  $(".panel-footer").on("click", '.user, .avatar', function(){
    var $comment = $(this).closest(".comment");
    var $button = $comment.find(".btn");
    var email = $button.attr("email");
    var name = $button.attr("name");
    var url = (name == null) ? "/home" : "/hub?user[email]=" + encodeURIComponent(email) + "&user[name]=" + encodeURIComponent(name);
    window.location.href = url;
  });

  $(".panel-heading > .user, .panel-heading > .avatar").click(function(){
    var $heading = $(this).closest(".panel-heading");
    var email = $heading.attr("email");
    var name = $heading.attr("name");
    var url = "/hub?user[email]=" + encodeURIComponent(email) + "&user[name]=" + encodeURIComponent(name);
    window.location.href = url;
  });

  $(".panel-footer").on("click", '.refer', function(){
    var flag = $(this).attr("flag")
    var email = $(this).attr("email");
    var name = $(this).attr("name");
    var url = (flag == "true") ? "/home" : "/hub?user[email]=" + encodeURIComponent(email) + "&user[name]=" + encodeURIComponent(name);
    window.location.href = url;
  });

  $("a.btn-post-delete").click(function(e){
    if (confirm('Are you sure?')){
      var $panel = $(this).closest(".panel-google-plus");
      var post_id = $panel.attr('id');
      if (sessionStorage.getItem("home-flag") == "true") {
        var n = sessionStorage.getItem("home-data");
        var m = $.parseJSON(n);
        var id = post_id;
        console.log(m);
        if (id in m){
          m[id] = [];
          var flag = true;
          for (var key in m){
            if((m[key]).length > 0){
              flag = false;
              break;
            }
          }
          console.log(flag);
          if (flag){
            sessionStorage.setItem("home-flag", "false");
          }
          else{
            sessionStorage.setItem("home-data", JSON.stringify(m));
          }
        }
      }
      return true;
    }
    return false;
  });

  $(".panel-footer").on("click", '.btn-comment-reply', function(){
    var email = $(this).attr('email');
    var name = $(this).attr('name');
    var $panel = $(this).closest('.panel-google-plus');
    var $comment = $panel.find('.panel-google-plus-comment');
        
    $comment.find('.btn:first-child').addClass('disabled');
    $comment.find('textarea').val('');
    $comment.find('textarea').attr("placeholder", "@" + name);
    $comment.find('button[type="submit"]').attr("email", email);
    
    if ($panel.hasClass('panel-google-plus-show-comment')) {
      $comment.find('textarea').focus();
    }
    else{
      $panel.toggleClass('panel-google-plus-show-comment');
    }
  });
  $('.panel-google-plus > .panel-footer > .input-placeholder, .panel-google-plus > .panel-google-plus-comment > .panel-google-plus-textarea > button[type="reset"]').on('click', function(event) {
    var $panel = $(this).closest('.panel-google-plus');
    var $comment = $panel.find('.panel-google-plus-comment');
        
    $comment.find('.btn:first-child').addClass('disabled');
    $comment.find('textarea').val('');
    $comment.find('textarea').attr("placeholder", "");
    $comment.find('button[type="submit"]').attr("email", "");
    
    $panel.toggleClass('panel-google-plus-show-comment');
    
    if ($panel.hasClass('panel-google-plus-show-comment')) {
      $comment.find('textarea').focus();
    }
  });
  $('.panel-google-plus-comment > .panel-google-plus-textarea > textarea').on('keyup', function(event) {
    var $comment = $(this).closest('.panel-google-plus-comment');
    
    $comment.find('button[type="submit"]').addClass('disabled');
    if ($(this).val().length >= 1) {
      $comment.find('button[type="submit"]').removeClass('disabled');
    }
  });

});