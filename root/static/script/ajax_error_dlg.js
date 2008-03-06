(function () {
    var ajax_dialog_init = function() {
        YAHOO.namespace("parley.ajax_dialog");

        var handleClose = function() {
            this.cancel();
        };

        YAHOO.parley.ajax_dialog.dlg =
            new YAHOO.widget.Dialog(
                "ajax_dialog",
                {
                    postmethod:             'none',
                    modal: true,
                    //width:                  '350px',
                    fixedcenter:            true,
                    visible:                false, 
                    constraintoviewport:    true,

                    buttons: [
                        { text:"Close", handler:handleClose, isDefault:true }
                    ]
                }
            )
        ; // End of new()

        YAHOO.parley.ajax_dialog.dlg.show_message = function(e) {
            try {
                // set the body of the dialog to the message, if we have one
                if(undefined!=e && undefined!=e.message) {
                    this.setBody(e.message);
                }
                else {
                    this.setBody('No error message passed to show_message()');
                }

                // set the dialog header
                if(undefined!=e && undefined!=e.title) {
                    this.setHeader(e.title);
                }
                else {
                    this.setHeader('Application Error');
                }
            } catch(e){alert(e);}

            // show the dialog
            this.show();
        }

        // Render the Dialog
        YAHOO.parley.ajax_dialog.dlg.render();
    };


    YAHOO.util.Event.onDOMReady(ajax_dialog_init);
})();
