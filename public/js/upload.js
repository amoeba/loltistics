$(document).ready(function() {
  var uploader = new qq.FileUploader({
    element: document.getElementById('file-uploader'),
    template: '<div class="qq-uploader"><div class="qq-upload-drop-area"><span>Drop files here to upload</span></div><div class="qq-upload-button">Select one or more files</div><ul class="qq-upload-list"></ul></div>',
    action: '/upload',
    allowedExtensions: ['log'],
    onComplete: function(id, fileName, responseJSON) {
      var html = '';
      
      if(responseJSON.matches.length == 0) {
        html += 'No matches found; ';
      } else {
        $.each(responseJSON.matches, function(i, m) {
          html += '<a href="/matches/' + m + '">' + m + '</a> ';
        });
      }
      
      if(responseJSON.players.length == 0) {
        html += 'No players found.';
      } else {
        $.each(responseJSON.players, function(i, p) {
          html += '<a href="/players/' + p + '">' + p + '</a> ';
        });
      }
      
      $("#output").append('<li>' + html + '</li>');
    }
  });
});