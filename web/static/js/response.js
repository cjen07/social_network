let response = {

  new_post(_payload){
    let count = get_count("info")
    select_helper("info", "new", ++count)
  },

  delete_post(payload){
    let id = payload.post_id
    if (!$("#" + id).length){
      let count = get_count("info")
      select_helper("info", "new", --count)
    }
    else{
      let count = get_count("danger")
      select_helper("danger", "deleted", ++count)
    }
  }  

}

function get_count(name){
  return Number.parseInt($(".alert-" + name).attr("count"))
}

function select_helper(name, type, count){
  if (count == 0){
    $(".alert-" + name).empty().attr("count", count)
    return
  }
  let text = (count == 1) ? "is a " : "are " + count + " "
  $(".alert-" + name).text("there " + text + type + " posts")
    .attr("count", count)
    .css('cursor', 'pointer')
    .click( _ => location.reload() )
}

export default response