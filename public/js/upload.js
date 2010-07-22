$(document).ready(function() {
  var uploader = new qq.FileUploader({
    element: document.getElementById('file-uploader'),
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
          html += '<a href="/matches/' + p + '">' + p + '</a> ';
        });
      }
      
      $("#output").append('<li>' + html + '</li>');
    }
  });
});