$(document).ready(function() {
  console.log("Uploader init");
  
  $('#upload-form').ajaxForm({
    beforeSubmit: function(arr, $form, options) {
      $("#output").append("<li><img src=\"/images/spinner.gif\" alt=\"(Working) \"/>Processing " + $form.children(":file").first().val() + "</li>");
    },
    success: function(responseText, statusText, xhr, $form) {
      $("#output li").last().html(responseText);
      $form.resetForm();
    }
  });
});