$(document).ready(function() {
  console.log("Uploader init");
  
  $('#upload-form').ajaxForm({
    success: function(responseText, statusText, xhr, $form) {
      $("#output")
    }
  });
});