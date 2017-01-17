$(document).on('click', '#close-preview', function(){ 
    $('.image-preview').popover('hide');
    $(".image-preview").attr("fix", false)
    // Hover before close the preview
    $('.image-preview').hover(
        function () {
            var fix = $(".image-preview").attr("fix");
            if (fix != "true"){
                $('.image-preview').popover('show');
            }
        }, 
        function () {
            var fix = $(".image-preview").attr("fix");
            if (fix != "true"){
                $('.image-preview').popover('hide');
            }
        }
    );    
});

$(function() {
    // Create the close button
    var closebtn = $('<button/>', {
        type:"button",
        text: 'x',
        id: 'close-preview',
        style: 'font-size: initial;',
    });
    closebtn.attr("class","close pull-right");
    // fix after click the preview
    $('.image-preview-filename').click(function(){
        $(".image-preview").attr("fix", true);
    });
    $('.image-preview').popover({
        trigger:'manual',
        html:true,
        title: "<strong>Preview</strong>"+$(closebtn)[0].outerHTML,
        content: "There's no image",
        placement:'bottom'
    });
    // Clear event
    $('.image-preview-clear').click(function(){
        $('.image-preview').attr("data-content","").popover('hide');
        $('.image-preview-filename').val("");
        $('.image-preview-clear').hide();
        $('.image-preview-input input:file').val("");
        $(".image-preview-input-title").text("Browse"); 
    }); 
    // Create the preview image
    $(".image-preview-input input:file").change(function (){     
        var img = $('<img/>', {
            id: 'dynamic',
            width:250,
            height:200
        });      
        var file = this.files[0];
        var size = file.size / 1000 / 1000;
        if (size > 2){
            alert("image size should be no more than 2MB");
            $('.image-preview-clear').click();
            return;
        }
        var reader = new FileReader();
        // Set preview image into the popover data-content
        reader.onload = function (e) {
            $(".image-preview-input-title").text("Change");
            $(".image-preview-clear").show();
            $(".image-preview-filename").val(file.name);            
            img.attr('src', e.target.result);
            $(".image-preview").attr("data-content",$(img)[0].outerHTML).popover("show");
        }        
        reader.readAsDataURL(file);
    });  
});