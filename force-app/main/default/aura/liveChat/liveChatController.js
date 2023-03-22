({
    /**
     * On initialization of this component, set the prechatFields attribute and render pre-chat fields.
     */
	onInit: function(cmp, evt, helper) {
        helper.getContact(cmp);
    },
    
    /**
     * Event which fires when start button is clicked in pre-chat
     */
    handleStartButtonClick: function(cmp, evt, helper) {
        helper.onStartButtonClick(cmp);
    }
});