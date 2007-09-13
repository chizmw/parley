/* Heavily borrowed from the example at:

     http://blog.davclass.com/

   Chisel Wright <chisel@herlpacker.co.uk>
*/

var YU = YAHOO.util;

var Editable = {
    config: {
        class_name: 'editable',
        trigger:    'click',    // or 'dblclick'
        min_size:   20,
    },
    max: function(x,y) {
        if (x>y) { return x; }
        return y;
    },
    init: function() {
        this.clicked  = false;
        this.contents = false;
        this.input    = false;
        
        _items = YU.Dom.getElementsByClassName(this.config.class_name);
        if (_items.length > 0) {
            for (i = 0; i < _items.length; i++) {
                YU.Event.addListener(
                    _items[i],
                    this.config.trigger,
                    Editable.triggered,
                    Editable,
                    true);
                YU.Event.addListener(
                    _items[i],
                    'keyup',
                    Editable.onKeyUp,
                    Editable,
                    true
                );
            }
        }
    },
    triggered: function(ev) {
        this.check();
        this.clicked = YU.Event.getTarget(ev, true);
        this.contents = this.clicked.innerHTML;
        this.create_input_field();
    },
    onKeyUp: function(p_oEvent) {
        var keyCode = YU.Event.getCharCode(p_oEvent);

        switch (keyCode) {
            case 13: // enter key
                this.check();
                break;

            case 27: // enter key
                // ideally we'd reset the box to its original value here
                this.reset_input_field();
                break;

            default:
                // do nothing
                break;
        }
    },
    create_input_field: function() {
        this.input = YU.Dom.generateId();
        new_input  = document.createElement('input');
        min_size   = this.max(this.contents.length, this.config.min_size);
        with (new_input) {
            setAttribute('type', 'text');
            setAttribute('id', this.input);
            value = this.contents;
            setAttribute('size', min_size);
            className = 'editable_input';
        }
        this.clicked.innerHTML = '';
        this.clicked.appendChild(new_input);

        this.create_save_button();
        this.create_cancel_button();

        new_input.select();
        // Add event listeners
        YU.Event.addListener(
            new_input,
            'blur',
            Editable.reset_input_field,
            Editable,
            true
        );
    },
    create_save_button: function() {
        // create the save button
        this.save_input  = YU.Dom.generateId();
        new_save_input   = document.createElement('input');
        with (new_save_input) {
            setAttribute('type', 'button');
            setAttribute('id', this.input);
            value = 'Save';
            className = 'editable_input';
        }
        // add it to the clicked element
        this.clicked.appendChild(new_save_input);
        // add a listener
        YU.Event.addListener(
            new_save_input,
            'click',
            Editable.check,
            Editable,
            true
        );
    },
    create_cancel_button: function() {
        // create the cancel button
        this.cancel_input  = YU.Dom.generateId();
        new_cancel_input   = document.createElement('input');
        with (new_cancel_input) {
            setAttribute('type', 'button');
            setAttribute('id', this.input);
            value = 'Cancel';
            className = 'editable_input';
        }
        // add it to the clicked element
        this.clicked.appendChild(new_cancel_input);
        // add a listener
        YU.Event.addListener(
            new_cancel_input,
            'click',
            Editable.reset_input_field,
            Editable,
            true
        );
    },
    reset_input_field: function() {
        this.clicked.innerHTML = this.contents;
        this.clicked  = false;
        this.contents = false;
        this.input    = false;
    },
    clear_input: function() {
        if (this.input) {
            if (YU.Dom.get(this.input).value.length > 0) {
                this.clean_input();
                this.contents_new = YU.Dom.get(this.input).value;
                this.clicked.innerHTML = this.contents_new;
            } else {
                this.contents_new = '[removed]';
                this.clicked.innerHTML = this.contents_new;
            }
        }
        this.callback();
        this.clicked  = false;
        this.contents = false;
        this.input    = false;
    },
    clean_input: function() {
        checkText   = new String(YU.Dom.get(this.input).value);
        regEx1      = /\"/g;
        checkText       = String(checkText.replace(regEx1, ''));
        YU.Dom.get(this.input).value = checkText;
    },
    check: function(ev) {
        if (this.clicked) {
            this.clear_input();
        }
    },
    callback: function() {
        console.log('callback()');
    }
}
