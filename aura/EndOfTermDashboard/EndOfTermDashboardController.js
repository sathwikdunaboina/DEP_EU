({
    doInit : function(cmp, event, helper) {
        //var vfOrigin = "https://infosys-custpoc.cs96.force.com/VolvoPOC";
        var urlString = window.location.href;
        var baseURL = urlString.substring(0, urlString.lastIndexOf("/s"))+'/apex/DashboardChart';
        //alert("windows"+baseURL)
        cmp.set("v.srcValue",baseURL);
        // https://infosys-custpoc.cs96.force.com/VolvoPOC/apex/IL_DashboardChart_VFPage
        // 
        var nearTerm=0;
        window.addEventListener("message", function(event) {
            if(event.data == 3 || event.data == 6)
            {
                cmp.set("v.timeToTerm",event.data);
                cmp.set("v.display",true);
            }
        }, false);
        
        var action = cmp.get("c.getAllContractTimeToTerm");
        action.setCallback(this,function(response){
            if(response.getState() == "SUCCESS"){
                var a=response.getReturnValue();
                cmp.set("v.contractList",a);
                cmp.set("v.TotalContracts",a.length);
                for(var i=0;i<a.length;i++){
                    if(a[i].End_of_Term__c == 3 || a[i].End_of_Term__c == 6)
                    {
                        nearTerm++;
                    }
                }
                cmp.set("v.nearTermContracts",nearTerm);
            }
        });
        $A.enqueueAction(action); 
    },
    
    handleChange :function(cmp, event, helper){
        var b=[];
        var time=cmp.get("v.timeToTerm");
        var contractList=cmp.get("v.contractList");
        for(var i=0;i<contractList.length;i++){
            if(contractList[i].End_of_Term__c==time)
            {
                b.push(contractList[i]);
            }
        }
        if(b.length >0){cmp.set("v.myMap",b);}
    },
    
    callmodal: function (component,event, helper) {
        var b=[];
        var recordId=event.target.id;
        component.set("v.timeToTerm",recordId);
        component.set("v.display",true);
    },
    
    callmodalforLightning: function (component,event, helper) {
        var b=[];
        var a = event.getSource();
        var id = a.getLocalId();
        component.set("v.timeToTerm",id);
        component.set("v.display",true);
    },
    
    contractDetail : function (cmp,event, helper) {
        var recordId=event.target.id;
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "/contract/" + recordId 
        });
        urlEvent.fire();
    },
    
    navigatecontract : function (cmp,event, helper) {
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "/contracts/" 
        });
        urlEvent.fire();
    },
    
    closeTerm: function (cmp,event, helper) {
        cmp.set("v.display",false);
        cmp.set("v.myMap",null);
    },
})