tinyMCE.init({
  // General options
  mode: 'none',
  theme: 'advanced',
/*  plugins: 'safari,spellchecker,pagebreak,style,layer,table,save,advhr,advimage,advlink,emotions,iespell,inlinepopups,insertdatetime,preview,media,searchreplace,print,contextmenu,paste,directionality,fullscreen,noneditable,visualchars,nonbreaking,xhtmlxtras,template,imagemanager,filemanager',*/
  plugins: 'safari,inlinepopups',
  dialog_type: "modal",
  
  // Theme options
/*  theme_advanced_buttons1 : "save,newdocument,|,bold,italic,underline,strikethrough,|,justifyleft,justifycenter,justifyright,justifyfull,|,styleselect,formatselect,fontselect,fontsizeselect",
  theme_advanced_buttons2 : "cut,copy,paste,pastetext,pasteword,|,search,replace,|,bullist,numlist,|,outdent,indent,blockquote,|,undo,redo,|,link,unlink,anchor,image,cleanup,help,code,|,insertdate,inserttime,preview,|,forecolor,backcolor",
  theme_advanced_buttons3 : "tablecontrols,|,hr,removeformat,visualaid,|,sub,sup,|,charmap,emotions,iespell,media,advhr,|,print,|,ltr,rtl,|,fullscreen",
  theme_advanced_buttons4 : "insertlayer,moveforward,movebackward,absolute,|,styleprops,spellchecker,|,cite,abbr,acronym,del,ins,attribs,|,visualchars,nonbreaking,template,blockquote,pagebreak,|,insertfile,insertimage",*/
  theme_advanced_toolbar_location : "top",
  theme_advanced_toolbar_align : "left",
  theme_advanced_statusbar_location : "bottom",
  theme_advanced_resizing : false
 
  // Office example CSS
/*  content_css : "css/office.css",

  // Drop lists for link/image/media/template dialogs
  template_external_list_url : "js/template_list.js",
  external_link_list_url : "js/link_list.js",
  external_image_list_url : "js/image_list.js",
  media_external_list_url : "js/media_list.js",

  // Replace values for the template plugin
  template_replace_values : {
    username : "Some User",
    staffid : "991234"
  }*/
});


$(function() {
  $('ul.adlib-page-sortable').sortable({ axis: 'y', handle: '.handle', update: function() {
    $.post('/adlib/pages/sort', '_method=put&'+$(this).sortable('serialize'));
  }});
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
                content = content.get(0);
                content = content.contentDocument || content.contentWindow && content.contentWindow.document || null;
                if (content) content = content.getElementsByTagName("body")[0].innerHTML; else content = '';
              } else {
                content = '';
              }
              $.ajax({
                type: 'post',
                url: button.form.action,
                data: $(button.form).serialize().replace(/adlib_snippet%5Bcontent%5D=[^&]*(&|$)/i, '') + 
                                     (content != '' ? '&adlib_snippet[content]=' + escape(content) : ''),
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
      /*$('p.adlib-form-textarea textarea').rte('/adlib/stylesheets/rte.css', '/adlib/stylesheets/rte-images/');*/
      $('p.adlib-form-textarea textarea').each(function() {
        tinyMCE.execCommand('mceAddControl', false, this.id);
      });      
    });
    return false;
  });
})
