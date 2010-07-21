$(document).ready(function() {
  console.log("Uploader init");
  
  $('#upload-form').ajaxForm({
    target: '#last_output',
    success: function(responseText, statusText, xhr, $form) {
    }
  });
});