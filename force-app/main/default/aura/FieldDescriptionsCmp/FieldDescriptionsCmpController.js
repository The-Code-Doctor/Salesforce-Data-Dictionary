({
	doInit : function(component, event, helper) {
        if(component.get('v.isAllCustomObjectsSelected')){
            helper.downloadData(component, event, helper);
        } else{
            var objectOptions = [];
            var action = component.get("c.getObjOptionsForFDs");
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
        }
	},
    
    setObjectsSelected : function(component, event, helper) {
		component.set('v.selectedObjects', event.getParam("value"));
    },
    
    downloadData : function(component, event, helper) {
        helper.downloadData(component, event, helper);
	}
})