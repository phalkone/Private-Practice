$(document).ready(function() {
  $(".list tr:even").css('background-color','#dddddd');
  $("#locale_picker").change(function() {
      $("#locale_picker form :submit").submit();
  });
  $('#image_picture').change(function() {
    var name = $("#image_picture").val().split(".");
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
});
function flash_hide(){
  $("#flash_notice").hide(300);
}
