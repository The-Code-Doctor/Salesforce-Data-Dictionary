({
	doInit : function(component, event, helper) {
		var objectOptions = [];
        var action = component.get("c.getObjectOptions");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var map = response.getReturnValue() ;
                for (var key in map) {
                    if (map.hasOwnProperty(key)) {
                        objectOptions.push({label: key, value: map[key]});
                    }
                };
                component.set('v.objectOptions', objectOptions);                
            }          
        });
        $A.enqueueAction(action);
	},
    
    setFieldsSelected : function(component, event, helper) {
		component.set('v.selectedFields', event.getParam("value"));
    },
    
    populateFieldOptions : function(component, event, helper) {
        var el=document.getElementsByClassName('logoutBox')[0];
        el.style.paddingBottom='0em';
		component.set('v.selectedObject', event.getParam("value"));
        var fieldOptions = [];
        var action = component.get("c.getFieldOptions");
        action.setParams({selectedObject : component.get("v.selectedObject")});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var map = response.getReturnValue() ;
                for (var key in map) {
                    if (map.hasOwnProperty(key)) {
                        fieldOptions.push({label: key, value: map[key]});
                    }
                };
                component.set('v.fieldOptions', fieldOptions);                
            }          
        });
        $A.enqueueAction(action);
	},
    
    downloadData : function(component, event, helper) {
        var action = component.get("c.getRecords");
        var selectedObjectName = component.get("v.selectedObject");
        action.setParams({selectedColumns : component.get("v.selectedFields"),
                          selectedObject : selectedObjectName});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS' && response.getReturnValue()){
                var hiddenElement = document.createElement('a');
                hiddenElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(response.getReturnValue());
                hiddenElement.target = '_blank';
                hiddenElement.download = selectedObjectName+'.csv'; 
                hiddenElement.click();
            }
        });
        $A.enqueueAction(action);
	}
})