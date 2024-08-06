({
    initialize: function(component, event, helper) {
        $A.get("e.siteforce:registerQueryEventMap").setParams({"qsToEvent" : helper.qsToEventMap}).fire();    
        $A.get("e.siteforce:registerQueryEventMap").setParams({"qsToEvent" : helper.qsToEventMap2}).fire();
        component.set('v.isUsernamePasswordEnabled', helper.getIsUsernamePasswordEnabled(component, event, helper));
        component.set("v.isSelfRegistrationEnabled", helper.getIsSelfRegistrationEnabled(component, event, helper));
        component.set("v.communityForgotPasswordUrl", helper.getCommunityForgotPasswordUrl(component, event, helper));
        component.set("v.communitySelfRegisterUrl", helper.getCommunitySelfRegisterUrl(component, event, helper));
        component.set("v.usernameLabel",'');
        component.set("v.passwordLabel",'');
        var i11=$A.get('$Browser.isIE11');
        var i10=$A.get('$Browser.isIE10');
        var i9=$A.get('$Browser.isIE9');
        var i8=$A.get('$Browser.isIE8');
        var i7=$A.get('$Browser.isIE7');
        var i6=$A.get('$Browser.isIE6');
        if(i11 || i10 || i9 || i8 || i7 || i6){
            component.set("v.ie",true);  
        }
    },
    
    openModalforselfregistration: function(cmp, evt, helper) {
        cmp.set("v.isselfregistration",true);
        
    },
    
    closeModalforselfregistration: function(cmp, evt, helper) {
        cmp.set("v.isselfregistration",false);
    },  
    
    saveforselfregistration: function(cmp, evt, helper) {
        var childCmp = cmp.find("child")
        childCmp.sampleMethod();
        
    }, 
    
    openModal:  function (component, event, helpler) {
        component.set("v.isOpen",true);
        helpler.getSupportContactDetails(component); 
        
    },
    
   
    
    closeModel:  function (component, event, helpler) {
        component.set("v.isOpen",false);
    },
    handleEnter: function (component, event, helpler) {
        if(event.which==13){
            helpler.handleLogin(component,component.get("v.usernameLabel") , component.get("v.passwordLabel"));
        }
    },
    
    handleLogin: function (component, event, helpler) {
        helpler.handleLogin(component,component.get("v.usernameLabel") , component.get("v.passwordLabel"));
    },
    
    setStartUrl: function (component, event, helpler) {
        var startUrl = event.getParam('startURL');
        if(startUrl) {
            component.set("v.startUrl", startUrl);
        }
    },
    
    setExpId: function (component, event, helper) {
        var expId = event.getParam('expid');
        if (expId) {
            component.set("v.expid", expId);
        }
        helper.setBrandingCookie(component, event, helper);
    },
    
    onKeyUp: function(component, event, helpler){
        //checks for "enter" key
        if (event.getParam('keyCode')===13) {
            helpler.handleLogin(component, event, helpler);
        }
    },
    
    navigateToForgotPassword: function(cmp, event, helper) {
        var forgotPwdUrl = cmp.get("v.communityForgotPasswordUrl");
        if ($A.util.isUndefinedOrNull(forgotPwdUrl)) {
            forgotPwdUrl = cmp.get("v.forgotPasswordUrl");
        }
        var attributes = { url: forgotPwdUrl };
        $A.get("e.force:navigateToURL").setParams(attributes).fire();
    },
    
    navigateToSelfRegister: function(cmp, event, helper) {
        var selrRegUrl = cmp.get("v.communitySelfRegisterUrl");
        if (selrRegUrl == null) {
            selrRegUrl = cmp.get("v.selfRegisterUrl");
        }
        
        var attributes = { url: selrRegUrl };
        $A.get("e.force:navigateToURL").setParams(attributes).fire();
    } 
})