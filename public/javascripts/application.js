$(document).ready(function() {
  $("#page_list tr:even").css('background-color','#dddddd');
  $("#locale_picker").change(function() {
      $("#locale_picker form :submit").submit();
  });
});
function flash_hide(){
  $("#flash_notice").hide(300);
}
