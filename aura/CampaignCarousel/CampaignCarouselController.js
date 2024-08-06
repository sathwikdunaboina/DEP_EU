({
    doInit : function(component, event, helper) {
        helper.fetchAllCampaigns(component);
    },
    goToNotification : function(component, event, helper){
        var i = event.currentTarget.getAttribute("data-value");
        component.set('v.transX','-'+i*100+'%');
        component.set('v.currentIndex',i);
    },
    previous : function(component, event, helper){
        var i = component.get('v.currentIndex');
        if(i>0) {
            i--; //going to previous index
        	component.set('v.transX','-'+i*100+'%');
        	component.set('v.currentIndex',i);
        }
    },
    next : function(component, event, helper){
        var i = component.get('v.currentIndex');
        var totalRecords = component.get('v.vfsCampaigns').length;
        i++; //going to next index
        if(i<totalRecords){
            component.set('v.transX','-'+i*100+'%');
            component.set('v.currentIndex',i);
        }
    }
})