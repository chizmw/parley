YAHOO.namespace("parley.suspend_reason");

function suspend_init() {
    var YU  = YAHOO.util,
        Dom = YAHOO.util.Dom;

    var suspend_account = function() {
        var elID = this.id,
            checked = (this.checked ? true : false);

        try {
            // do we want to suspend the tinker?
            if (checked) {
                YAHOO.parley.suspend_reason.suspend_reason_dialog.show();
            }

            // do we want to un-suspend the user?
            else {
                //alert('un-suspend');
            }
        } catch(e) { alert(e); }
    }

    YU.Event.addListener(
        'suspend_account',
        'change',
        suspend_account
    );
}


function suspend_reason_init() {
    var YU  = YAHOO.util,
        Dom = YAHOO.util.Dom;

    // Define various event handlers for Dialog
    var handleSubmit = function() {
        YAHOO.parley.small_loading.wait.show();

        var checked =
            (Dom.get('suspend_account').checked ? 1 : 0);

        var person_id =
            Dom.get('suspend_account').value;
        var reason =
            Dom.get('suspension_reason').value;

        try {
            var request = YU.Connect.asyncRequest(
                'POST',
                '/user/suspend',
                {
                    success: handleSuccess,
                    failure: handleFailure,
                    argument: {
                        node: Dom.get('suspend_account')
                    }
                },
                  'suspend='    + checked
                + '&person='    + person_id
                + '&reason='    + reason
            );
        } catch(e) { alert(e); }
    };
    var handleCancel = function() {
        YAHOO.parley.small_loading.wait.hide();
        this.cancel();
    };
    var handleSuccess = function(o) {
        YAHOO.parley.small_loading.wait.hide();
        YAHOO.parley.suspend_reason.suspend_reason_dialog.hide();
        var response = o.responseText;
        var data = eval('(' + o.responseText + ')');

        try {
        YAHOO.parley.ajax_dialog.dlg.show_message(data.error);
        } catch(e) { alert(e); }
    };
    var handleFailure = function(o) {
        YAHOO.parley.small_loading.wait.hide();
        alert("Submission failed: " + o.status);
    };

    // Instantiate the Dialog
    YAHOO.parley.suspend_reason.suspend_reason_dialog =
        new YAHOO.widget.Dialog("suspend_reason_dialog",
        {
            postmethod:             'async',
            width : "350px",
            fixedcenter : true,
            visible : false, 
            constraintoviewport : true,
            buttons : [ { text:"Submit", handler:handleSubmit, isDefault:true },
                        { text:"Cancel", handler:handleCancel } ]
        }
    );

    // Render the Dialog
    YAHOO.parley.suspend_reason.suspend_reason_dialog.render();
}

YAHOO.util.Event.onDOMReady(suspend_reason_init);
YAHOO.util.Event.onDOMReady(suspend_init);

