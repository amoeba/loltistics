$(document).ready(function() {
  console.log("Uploader init");
  
  $('#upload-form').ajaxForm({
    beforeSubmit: function(arr, $form, options) {
      var filename = $form.children(":file").first().val();
      $("#output").append("<li data-filename=\"" + filename + "\"><img src=\"/images/spinner.gif\" alt=\"(Working) \"/>Uploading and Processing " + filename + "</li>");
    },
    success: function(responseText, statusText, xhr, $form) {
      $("#output li").each(function() {
        var filename = $form.children(":file").first().val();
        var current_filename = $(this).attr('data-filename')
        
        if(current_filename && filename == current_filename) {
          $(this).html(responseText);
        }
      });
      $form.resetFields();
    }
  });
});