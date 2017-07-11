.. _#tutorialLongTitle#:

#tutorialTitle#
#underline#

.. raw:: html

    <style>
    h1  {font-size:0px}
    </style>
    <div style="margin:-30px; margin-right:-30px;">
      <iframe src="../_static/tutorials/#tutorialName#" width="100%" scrolling="yes" id="iFrameResizer0" style="overflow: visible; height: 228px;" frameborder="0"></iframe>
    </div>

    <script type="text/javascript" src="../_static/js/iframeResizer.min.js"></script>
    <script type="text/javascript">

      iFrameResize({
        log                     : true,                  // Enable console logging
        enablePublicMethods     : true,                  // Enable methods within iframe hosted page
        resizedCallback         : function(messageData){ // Callback fn when resize is received
          $('p#callback').html(
            '<b>Frame ID:</b> '    + messageData.iframe.id +
            ' <b>Height:</b> '     + messageData.height +
            ' <b>Width:</b> '      + messageData.width +
            ' <b>Event type:</b> ' + messageData.type
          );
        },
        messageCallback         : function(messageData){ // Callback fn when message is received
          $('p#callback').html(
            '<b>Frame ID:</b> '    + messageData.iframe.id +
            ' <b>Message:</b> '    + messageData.message
          );
          alert(messageData.message);
        },
        closedCallback         : function(id){ // Callback fn when iFrame is closed
          $('p#callback').html(
            '<b>IFrame (</b>'    + id +
            '<b>) removed from page.</b>'
          );
        }
      });
    </script>
