.. _practica_COBRA_primer:

tutorialNoName
==============


.. raw:: html

    <div class="wrapper">
        <ul class="metro">
            <li class="small-tile-text color_class5 scale-10">
                <a class="tile" style="width: 90px; height: 90px;" href="cobratoolbox/stable/tutorials/base/primer/practical_COBRA_primer.pdf">
                    <img src="/cobratoolbox/stable/_static/img/icon5.png" height="90px" alt="PDF file">
                </a>
                <div>Download PDF</div>
            </li>
            &nbsp;&nbsp;&nbsp;&nbsp;
            <li class="small-tile-text color_class6 scale-10">
                <a class="tile" style="width: 90px; height: 90px;" href="https://github.com/opencobra/COBRA.tutorials/raw/master/base/primer/practical_COBRA_primer.mlx">
                <img src="/cobratoolbox/stable/_static/img/icon6.png" height="90px" alt="live Script">
                </a>
                  <div>Download live Script</div>
            </li>
            &nbsp;&nbsp;&nbsp;&nbsp;
            <li class="small-tile-text color_class7 scale-10">
                <a class="tile" style="width: 90px; height: 90px;" href="https://github.com/opencobra/COBRA.tutorials/raw/master/base/primer/practical_COBRA_primer.m">
                <img src="/cobratoolbox/stable/_static/img/icon7.png" height="90px" alt="m file">
                </a>
                  <div>Download m file</div>
            </li>
            &nbsp;&nbsp;&nbsp;&nbsp;
            <li class="small-tile-text color_class8 scale-10">
                <a class="tile" style="width: 90px; height: 90px;" href="https://github.com/opencobra/COBRA.tutorials/tree/master/base/primer">
                <img src="/cobratoolbox/stable/_static/img/icon8.png" height="90px" alt="GitHub">
                </a>
                  <div>View on GitHub</div>
            </li>
            &nbsp;&nbsp;&nbsp;&nbsp;
            <li class="small-tile-text color_class2 scale-10">
                <a class="tile" style="width: 90px; height: 90px;" href="https://opencobra.github.io/cobratoolbox/latest/tutorials/index.html">
                <img src="/cobratoolbox/stable/_static/img/icon2.png" height="90px" alt="tutorials">
                </a>
                  <div>Tutorials</div>
            </li>
        </ul>
    </div>
    <br>


.. raw:: html

    <style>
    h1  {font-size:0px}
    </style>
    <div style="margin:-30px; margin-right:-30px;">
      <iframe src="cobratoolbox/stable/tutorials/base/primer/iframe_practical_COBRA_primer.html" width="100%" scrolling="yes" id="iFrameResizer0" style="overflow: visible; height: 228px;" frameborder="0"></iframe>
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
