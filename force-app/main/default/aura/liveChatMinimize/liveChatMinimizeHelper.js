({
    minimizedEventHandler: function(cmp, eventName, eventData) {



        switch(eventName) {
				//case "prechatState":
               //cmp.set("v.message", "CHAT WITH AN EXPERT");
              //  Break;
            
            case "waitingEndedState":
                this.showModal(cmp);
                break;
            default:
                break;
        }
    },
    showModal: function(cmp) {
               
               
                cmp.find('modal').showCustomModal({
                    header: 'No Agents are available right now, Please check after sometime',
                    body: 'No Agents are available',
                    showCloseButton: true,
                    closeCallback: function() {

                    }
                });
    }
})