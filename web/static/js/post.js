import helper from "./helper"

$(document).ready(function() {
  if ( sessionStorage.getItem("warning") == "true" ) {
    $(".alert-warning").text("updated by another endpoint")
    sessionStorage.setItem("warning", "false")
  }

  let offset = 10

  if ($(this).scrollTop() < offset) {
    $('.back-to-top').hide()
  }
})  

$(window).scroll(function() {

  let offset = 10
  let duration = 300

  if ($(this).scrollTop() > offset) {
    $('.back-to-top').fadeIn(duration)
  } else {
    $('.back-to-top').fadeOut(duration)
  }
})

$('.back-to-top').click(function(event) {
  event.preventDefault()  
  $('html, body').animate({scrollTop: 0}, "slow")
  return false
})

$('.btn-heart').click(function(){
  $(this).blur()
  let post_id = $(this).attr('id')
  let span_id = $(this).find(".glyphicon").attr('id')
  $.get("/api/thumb?post_id=" + post_id + "&span_id=" + span_id,
    function (data){
      if (data.error){
        alert(data.error)
        return
      }
      $(".btn-heart[id='" + post_id + "']").empty()
      if (data.thumb) {
        $(".btn-heart[id='" + post_id + "']").append("<span id='0' class='glyphicon glyphicon-heart glyphicon-btn'></span>")
      }
      else {
        $(".btn-heart[id='" + post_id + "']").append("<span id='1' class='glyphicon glyphicon-heart-empty glyphicon-btn'></span>")
      }

      $("#thumb_" + post_id).empty()
      let thumbs = data.thumbs
      if (thumbs.length != 0){
        if (data.has_image){
          $("#thumb_" + post_id).append("<br>")
        }
        $("#thumb_" + post_id).append("<span class='glyphicon glyphicon-heart glyphicon-thumb'></span> ")
        thumbs.forEach(function (e){
          if (e.self){
            $("#thumb_" + post_id).append("<a class='btn btn-default btn-xs btn-thumb' email='" + e.email + "' href='/home'>" + e.name + "</a> ")
          }
          else{
            let name = encodeURIComponent(e.name)
            let email = encodeURIComponent(e.email)
            $("#thumb_" + post_id).append("<a class='btn btn-default btn-xs btn-thumb' email='" + e.email + "' href=/hub?user[email]=" + email + "&ampuser[name]=" + name + ">" + e.name + "</a> ")
          }
        })
      }

    }, "json")
})
$('.btn-comment-create').click(function(){
  let $panel = $(this).closest('.panel-google-plus')
  let $comment = $panel.find('.panel-google-plus-comment')
  let post_id = $(this).attr('id')
  let email = $(this).attr('email')
  let text = $comment.find('textarea').val()
  $.get("/api/comment/create?post_id=" + post_id 
    + "&comment=" + encodeURIComponent(text)
    + "&email=" + encodeURIComponent(email),
    data => helper.comment_helper(data, post_id), "json")
  $comment.find('button[type="reset"]').click()
})
$(".panel-footer").on("click", '.btn-comment-delete', function(){
  let post_id = $(this).attr('id')
  let time = $(this).attr('time')
  $.get("/api/comment/delete?post_id=" + post_id + "&time=" + time,
    data => helper.comment_helper(data, post_id), "json")
})

$(".panel-footer").on("click", '.user, .avatar', function(){
  let $comment = $(this).closest(".comment")
  let $button = $comment.find(".btn")
  let email = $button.attr("email")
  let name = $button.attr("name")
  let url = (name == null) ? "/home" : "/hub?user[email]=" + encodeURIComponent(email) + "&user[name]=" + encodeURIComponent(name)
  window.location.href = url
})

$(".panel-heading > .user, .panel-heading > .avatar").click(function(){
  let $heading = $(this).closest(".panel-heading")
  let email = $heading.attr("email")
  let name = $heading.attr("name")
  let url = "/hub?user[email]=" + encodeURIComponent(email) + "&user[name]=" + encodeURIComponent(name)
  window.location.href = url
})

$(".panel-footer").on("click", '.refer', function(){
  let flag = $(this).attr("flag")
  let email = $(this).attr("email")
  let name = $(this).attr("name")
  let url = (flag == "true") ? "/home" : "/hub?user[email]=" + encodeURIComponent(email) + "&user[name]=" + encodeURIComponent(name)
  window.location.href = url
})

$("a.btn-post-delete").click(function(e){
  if (confirm('Are you sure?')){
    let $panel = $(this).closest(".panel-google-plus")
    let post_id = $panel.attr('id')
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
    return true
  }
  return false
})

$(".panel-footer").on("click", '.btn-comment-reply', function(){
  let email = $(this).attr('email')
  let name = $(this).attr('name')
  let $panel = $(this).closest('.panel-google-plus')
  let $comment = $panel.find('.panel-google-plus-comment')
      
  $comment.find('.btn:first-child').addClass('disabled')
  $comment.find('textarea').val('')
  $comment.find('textarea').attr("placeholder", "@" + name)
  $comment.find('button[type="submit"]').attr("email", email)
  
  if ($panel.hasClass('panel-google-plus-show-comment')) {
    $comment.find('textarea').focus()
  }
  else{
    $panel.toggleClass('panel-google-plus-show-comment')
  }
})
$('.panel-google-plus > .panel-footer > .input-placeholder, .panel-google-plus > .panel-google-plus-comment > .panel-google-plus-textarea > button[type="reset"]').on('click', function(event) {
  let $panel = $(this).closest('.panel-google-plus')
  let $comment = $panel.find('.panel-google-plus-comment')
      
  $comment.find('.btn:first-child').addClass('disabled')
  $comment.find('textarea').val('')
  $comment.find('textarea').attr("placeholder", "")
  $comment.find('button[type="submit"]').attr("email", "")
  
  $panel.toggleClass('panel-google-plus-show-comment')
  
  if ($panel.hasClass('panel-google-plus-show-comment')) {
    $comment.find('textarea').focus()
  }
})
$('.panel-google-plus-comment > .panel-google-plus-textarea > textarea').on('keyup', function(event) {
  let $comment = $(this).closest('.panel-google-plus-comment')
  
  $comment.find('button[type="submit"]').addClass('disabled')
  if ($(this).val().length >= 1) {
    $comment.find('button[type="submit"]').removeClass('disabled')
  }
})