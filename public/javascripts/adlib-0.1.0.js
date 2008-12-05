$(function() {
  $('div.adlib-richtext').hover(function() {
    $(this).addClass('iehover');
  }, function() {
    $(this).removeClass('iehover');
  });
  $('div.adlib-richtext').click(function() {
    $(this).children('a.adlib-richtext-edit').click();
  });
  $('a.adlib-modal-dialog, a.adlib-richtext-edit').click(function() {
    var d = $('#adlib_modal_dialog');
    if (d.length != 0) d.dialog('destroy');
    d = $('<div style="display:none"><div id="adlib_modal_dialog"></div></div>').appendTo('body');
    d = $('#adlib_modal_dialog');
    d.load($(this).attr('href'), null, function() {
      var content = $(this).children('div');
      var buttons = {};
      $('#adlib_modal_dialog form').submit(function() {
        var defaultButton = $('#adlib_modal_dialog').parents('.ui-dialog').find('button:first');
        defaultButton.click();
        return false;
      });
      $('#adlib_modal_dialog .adlib-form-buttons')
        .css('display', 'none')
        .children('input, a').each(function() {
          var button = this;
          if (this.tagName == 'A') {
            buttons[$(this).text()] = function() { 
              $(this).dialog('close');
            }
          } else {
            buttons[this.value] = function() {
              var content = $('#adlib_modal_dialog iframe');
              if (content.length == 1) {
                content = content.get(0).contentWindow.document.getElementsByTagName("body")[0].innerHTML;
              } else {
                content = '';
              }
              $.ajax({
                type: 'post',
                url: button.form.action,
                data: $(button.form).serialize() + (content != '' ? '&adlib_snippet[content]=' + escape(content) : ''),
                dataType: 'xml',
                error: function(xhr) {
                  var errorMessage = '';
                  $(xhr.responseXML).find('error').each(function() {
                    errorMessage += $(this).text() + unescape('%0A');
                  });
                  alert(errorMessage);
                },
                success: function(xhr) {
                  var redirect = $(xhr).find('redirect');
                  if (redirect.length > 0) {
                    window.location.href = $(redirect[0]).text();
                  } else window.location.reload();
                }              
              });
            };
          }
        });
      $(this).dialog({
        modal: true,
        overlay: {
          opacity: 0.5,
          background: 'black'
        },
        buttons: buttons,
        title: content.attr('title'),
        width: content.attr('width'),
        height: content.attr('height')
      }).dialog('open');
      $(this).css('display', 'block');
      $('p.adlib-form-textarea textarea').rte('/adlib/stylesheets/rte.css', '/adlib/stylesheets/rte-images/');
    });
    return false;
  });
})
