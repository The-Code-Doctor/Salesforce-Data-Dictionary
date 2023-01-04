({
	downloadData : function(component, event, helper) {
        var action;
        if(component.get('v.isAllCustomObjectsSelected')){
            action = component.get("c.getFieldDefinitionsForAllObjects");
        }
        else{
            action = component.get("c.getFieldDefinitionsForSelectedObjects");
            action.setParams({selectedObjects : component.get("v.selectedObjects")});
        }
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS' && response.getReturnValue()){
                var hiddenElement = document.createElement('a');
                hiddenElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(response.getReturnValue());
                hiddenElement.target = '_blank';
                hiddenElement.download = 'FieldDescriptions.csv'; 
                hiddenElement.click();
            }
        });
        $A.enqueueAction(action);
	}
})