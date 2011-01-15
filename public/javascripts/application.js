$(document).ready(function() {
 $('#login_box a.login').click(function() {
   $('#login_box form').slideToggle();
   return false;
 });
 $('#login_box').mouseleave(function() {
   $(window).mouseover(function(e){
     x_corr = e.pageX;
     y_corr = e.pageY;
   });
   setTimeout(login_hide,750);
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

 setTimeout(flash_hide,3000);
});
function login_hide(){
  if( (y_corr > $('#login_box').height()) || (x_corr < $('#login_box').offset().left) || (x_corr > ($('#login_box').width() + $('#login_box').offset().left)) ) {
    $('#login_box form').slideUp();
    $(window).unbind("mouseover");
  }
}
function flash_hide(){
  $(".flash").hide(300);
}
function linkbox() {
  $(".link_box").each(function() {
    $(this)
    .attr("readOnly","readOnly")
    .mouseup(function() {
      return false;
    })
    .mousedown(function() {
      $(this).select();
    })
    .focus(function() {
      $(this).select();
    });
  });
}
function lightbox() {
  $('a.lightbox.picture').click(function(e) {
    createLightbox();
    lightboxImage(this);
    return false;   
  });
  $('a.lightbox.frame').click(function(e) {
    createLightbox();
    lightboxFrame(this);
    return false;   
  });
}
function createLightbox(){
 $('body').css('overflow-y', 'hidden');
 $('body').css('overflow-x', 'hidden');
 $('<div id="overlay"></div>')
   .css('top', $(document).scrollTop())
   .css('opacity', '0')
   .animate({'opacity': '0.5'}, 'slow')
   .click(function() {
     removeLightbox();
   })
     .appendTo('body');
  $('<div id="lightbox"></div>')
    .hide()
    .appendTo('body');
}
function lightboxImage(e){
  $('<img />')
    .attr('src', $(e).attr('href'))
    .load(function() {
      positionLightboxImage();
    })
    .click(function() {
      removeLightbox();
    })
    .appendTo('#lightbox');
}
function lightboxFrame(e){
  $('<iframe />')
    .attr({ 'src': $(e).attr('href'),
            'width': $(window).width()-300,
            'height': $(window).height()-30
    })
    .css({
      'background': 'white',
      'opacity':'1',
      'border':'0'
    })
    .load(function() {
      positionLightboxFrame();
    })
    .click(function() {
      removeLightbox();
    })
    .appendTo('#lightbox');
}
function positionLightboxFrame() {
  $('#lightbox')
  .css({
    'top': 15 + $(document).scrollTop(),
    'left': 150
  })
  .fadeIn();
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
