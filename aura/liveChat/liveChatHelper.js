({
    getContact: function (cmp) {
        
        var action = cmp.get('c.getContactDetail');
        var that = this;
        action.setCallback(this, function (result) {
            if (result.getState() === 'SUCCESS') {
                var user = result.getReturnValue();
                cmp.set('v.contact', user.contact);
                cmp.set('v.user', user);
                that.getComponents(cmp);
                
            } else {
                console.log(result.getError());
            }
        });
        $A.enqueueAction(action);
    },
    
    getComponents: function (cmp) {
        var prechatFields = cmp.find("prechatAPI").getPrechatFields();
        console.log('prechatFields');
        console.table(prechatFields);
        
        // Get pre-chat field types and attributes to be rendered
        var prechatFieldComponentsArray = this.getPrechatFieldAttributesArray(cmp, prechatFields);
        
        
        // Make asynchronous Aura call to create pre-chat field components
        $A.createComponents(
            prechatFieldComponentsArray,
            function(components, status, errorMessage) {
                if(status === "SUCCESS") {
                    cmp.set("v.prechatFieldComponents", components);
                }
            }
        );
    },
    
    /**
	 * Map of pre-chat field label to pre-chat field name (can be found in Setup)
	 */
    fieldLabelToName: {
        //Italian Translation 
        "Nome": "FirstName",
        "Cognome": "LastName",
        "Oggetto": "Subject",
        "nazione": "Country__c",
        
        //English Translation
        "First Name": "FirstName",
        "Last Name": "LastName",
        "Subject": "Subject",
        "Country": "Country__c",
        'Email' : "Email"
    },
    
    /**
	 * Event which fires the function to start a chat request (by accessing the chat API component)
	 *
	 * @param cmp - The component for this state.
	 */
    onStartButtonClick: function(cmp) {
        var prechatFieldComponents = cmp.find("prechatField");
        var fields;
        var falseCheck = 0;
        // Make an array of field objects for the library
        fields = this.createFieldsArray(prechatFieldComponents);
        console.log('---> validate function ... ');
        var valResult = cmp.find("prechatAPI").validateFields(fields);
        console.log(JSON.parse(JSON.stringify(cmp.find("prechatAPI").validateFields(fields))));
        
        // If the pre-chat fields pass validation, start a chat
        fields.forEach(function(item,index){
                if(!fields[index].value) {
                    falseCheck = falseCheck + 1;
                    var ermsg = cmp.find("errorMsg");
                    $A.util.removeClass(ermsg, 'slds-hidden');
                } 
        });
        if(falseCheck=='0'){
            if (cmp.find("prechatAPI").validateFields(fields).valid) {
                cmp.find("prechatAPI").startChat(fields);
            } else {
                console.warn("Prechat fields did not pass validation!");
            }
        }
        
    },
    
    /**
	 * Create an array of field objects to start a chat from an array of pre-chat fields
	 * 
	 * @param fields - Array of pre-chat field Objects.
	 * @returns An array of field objects.
	 */
    createFieldsArray: function(fields) {
        if(fields.length) {
            return fields.map(function(fieldCmp) {
                return {
                    label: fieldCmp.get("v.label"),
                    value: fieldCmp.get("v.value"),
                    name: this.fieldLabelToName[fieldCmp.get("v.label")]
                };
            }.bind(this));
        } else {
            return [];
        }
    },
    
    
    getPrechatFieldAttributesArray: function(cmp, prechatFields) {
        // $A.createComponents first parameter is an array of arrays. Each array contains the type of component being created, and an Object defining the attributes.
        var prechatFieldsInfoArray = [];
        
        // For each field, prepare the type and attributes to pass to $A.createComponents
        prechatFields.forEach(function(field) {
            
            var componentName = (field.type === "inputSplitName") ? "inputText" : field.type;
            var componentInfoArray = ["ui:" + componentName];
            var attributes = {
                label : field.label,
                "aura:id": "prechatField",
                required: field.required,
                disabled: field.readOnly,
                maxlength: field.maxLength,
                class: field.className,
                id: field.label
            };
            // Special handling for options for an input:select (country picklist) component
            var country = cmp.get('v.user.Country');
            console.log('--> country is --> '+ country);
            if(field.type === "inputSelect" && field.picklistOptions) {
                attributes.options = field.picklistOptions;
                var selectedIndex = 0;
                attributes.options.forEach(function(option, index) {
                    if (option.value == country){
                        selectedIndex = index;
                    }
                    else
                    {
                        attributes.options[index].class = "slds-hidden";
                    }
                });
                attributes.options[selectedIndex].selected = true;
            } else if (attributes.class.includes('FirstName') || attributes.class.includes('LastName') || attributes.class.includes('Email')){
                attributes.value = field.value;
                attributes.disabled = "true";  
            }
                else {
                    attributes.value = field.value;
                }
            
            // Append the attributes Object containing the required attributes to render this pre-chat field
            componentInfoArray.push(attributes);
            
            // Append this componentInfoArray to the fieldAttributesArray
            prechatFieldsInfoArray.push(componentInfoArray);
            
            
        });
        return prechatFieldsInfoArray;
    }
});