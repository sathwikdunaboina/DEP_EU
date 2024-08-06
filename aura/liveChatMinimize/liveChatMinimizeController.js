({
    onInit: function(cmp, evt, helper) {
        cmp.find("minimizedAPI").registerEventHandler(helper.minimizedEventHandler.bind(helper, cmp));
    },
    handleMaximize: function(cmp, evt, helper) {
        cmp.find("minimizedAPI").maximize();
    }
})