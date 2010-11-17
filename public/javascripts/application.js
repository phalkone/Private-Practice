$(document).ready(function() {
  $("#locale_picker").change(function() {
      $("#locale_picker form :submit").submit();
  });
  $('#file_picture').change(function() {
    var name = $("#file_picture").val().split(".");
    var ext = name[name.length-1];
    $("#image_filetype").val(ext);
  });
  $('input.clear').each(function() {
    $(this)
    .data('default', $(this).val())
    .addClass('inactive')
    .focus(function() {
      $(this).removeClass('inactive');
      if ($(this).val() == $(this).data('default') || '') {
        $(this).val('');
      }
    })
    .blur(function() {
      var default_val = $(this).data('default');
      if ($(this).val() == '') {
        $(this).addClass('inactive');
        $(this).val($(this).data('default'));
      }
    });
  });
  $("#hide_pass").focus(function() {
    $("#hide_pass").hide();
    $("#show_pass").show().focus();
  })
  $("#show_pass").blur(function() {
    if ($(this).val() == "") {
      $("#hide_pass").show();
      $("#show_pass").hide();
    }
  });
  lightbox();
  zebra();
  setTimeout(flash_hide,3000);
});
function flash_hide(){
  $("#flash_notice").hide(300);
}
function lightbox() {
  $('a.lightbox').click(function(e) {
    $('body').css('overflow-y', 'hidden');
    $('body').css('overflow-x', 'hidden');
    $('<div id="overlay"></div>')
      .css('top', $(document).scrollTop())
      .css('opacity', '0')
      .animate({'opacity': '0.5'}, 'slow')
      .appendTo('body');
    $('<div id="lightbox"></div>')
      .hide()
      .appendTo('body');
    $('<img />')
      .attr('src', $(this).attr('href'))
      .load(function() {
        positionLightboxImage();
      })
      .click(function() {
        removeLightbox();
      })
      .appendTo('#lightbox');
    return false;
  });
}
function positionLightboxImage() {
  if ($(window).width() < $("#lightbox").width()){
    $("#lightbox img").attr("width",$(window).width()-30);
  }
  if($(window).height() < $("#lightbox").height()){
    $("#lightbox img").removeAttr("width");
    $("#lightbox img").attr("height",$(window).height()-30);
  }
 
  var top = ($(window).height() - $('#lightbox').height()) / 2;
  var left = ($(window).width() - $('#lightbox').width()) / 2;
  $('#lightbox')
  .css({
    'top': top + $(document).scrollTop(),
    'left': left
  })
  .fadeIn();
}
function removeLightbox() {
  $('#overlay, #lightbox')
  .fadeOut('slow', function() {
    $(this).remove();
    $('body').css('overflow-y', 'auto');
    $('body').css('overflow-x', 'auto');
  });
}
function zebra() {
  $(".list tr:even").css('background-color','#dddddd');
}
