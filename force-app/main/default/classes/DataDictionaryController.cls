/*
 * Using this in a PRODUCTION environment could be risky as this runs in the SYSTEM CONTEXT (doesn't follow access restrictions)
*/
public class DataDictionaryController {

    /* ================================================
      *@description : The method returns all the custom object names and labels available as a Map
      *@return : Map<String,String>
     ================================================*/
    @AuraEnabled
    public static Map<String,String> getObjectOptions () {
        Map<String,String> objectOptions = new Map<String,String>();
        for(Schema.SObjectType objTyp : Schema.getGlobalDescribe().Values()){
            //We can hide any objects with __Tag,__ChangeEvent,__Share,__History or __e extensions objects by keeling conditions like below:
            //if(!objTyp.getDescribe().getName().endsWithIgnoreCase('__Tag'))
            objectOptions.put(objTyp.getDescribe().getLabel(), objTyp.getDescribe().getName());
        }
        
        //Sort Object Names by Labels
		Map<String,String> sortedObjectOptions = new Map<String,String>();
        List<String> keyList = new List<String>();
        keyList.addAll(objectOptions.keySet());
        keyList.sort();
        sortedObjectOptions.put('--Select--','');
        for(String key : keyList){
            sortedObjectOptions.put(key, objectOptions.get(key));
        }
        return sortedObjectOptions;
    }
    
    /* ================================================
      *@description : The method returns all the objects available as a Map for the Field Descriptions
      *@return : Map<String,String>
     ================================================*/
    @AuraEnabled
    public static Map<String,String> getObjOptionsForFDs () {
        Map<String,String> objectOptions = new Map<String,String>();
        for(Schema.SObjectType objTyp : Schema.getGlobalDescribe().Values()){
            /*Currently ignoring the Objects with extensions __Tag,__ChangeEvent,__Share,__History or __e 
			since they will be almost same as corresponding __c object. 
			Feel free to remove the below condition if that restriction needs to be removed*/
                if(!(objTyp.getDescribe().getName().endsWithIgnoreCase('__Tag') ||
                     objTyp.getDescribe().getName().endsWithIgnoreCase('__ChangeEvent') ||
                     objTyp.getDescribe().getName().endsWithIgnoreCase('__Share') ||
                     objTyp.getDescribe().getName().endsWithIgnoreCase('__History'))){
                         objectOptions.put(objTyp.getDescribe().getLabel(), 
                                           objTyp.getDescribe().getName());
                     }
        }
        //Sort Object Names by Labels
        Map<String,String> sortedObjectOptions = new Map<String,String>();
        List<String> keyList = new List<String>();
        keyList.addAll(objectOptions.keySet());
        keyList.sort();
        for(String key : keyList){
            sortedObjectOptions.put(key, objectOptions.get(key));
        }
        return sortedObjectOptions;
    }
    
    /* ================================================
      *@description : The method returns all the custom object names and labels available as a Map
	   @param : selectedObject - API Name of the Selected object for which the Field Options need to be returned
      *@return : Map<String,String>
     ================================================*/
    @AuraEnabled
    public static Map<String,String> getFieldOptions (String selectedObject) {
        Map<String,String> fieldOptions = new Map<String,String>();
        if(String.isNotBlank(selectedObject)){
            Map<String,Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().
                get(selectedObject).
                getDescribe().fields.getMap();
            for(Schema.SObjectField field : fieldMap.values()){
                Schema.DescribeFieldResult fieldResult = field.getDescribe();   
                if(fieldResult.isAccessible()){
                    fieldOptions.put(fieldResult.getLabel(), fieldResult.getName());
                }
            }
        }
        //Sort Object Names by Labels
		Map<String,String> sortedFieldOptions = new Map<String,String>();
        List<String> keyList = new List<String>();
        keyList.addAll(fieldOptions.keySet());
        keyList.sort();
        sortedFieldOptions.put('All Fields','All');
        for(String key : keyList){
            sortedFieldOptions.put(key, fieldOptions.get(key));
        }
        return sortedFieldOptions;
    }
    
    /* ================================================
      *@description : The method returns the list of all the fields in the selectedObject
	   @param : selectedObject - API Name of the Selected object for which the Field Options need to be returned
      *@return : List<String>
     ================================================*/
    private static List<String> getAllFieldsOfObject(String selectedObject){
        List<String> allFieldsOfObject = new List<String>();
        if(String.isNotBlank(selectedObject)){
            Map<String,Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().
                get(selectedObject).
                getDescribe().fields.getMap();
            for(Schema.SObjectField field : fieldMap.values()){
                Schema.DescribeFieldResult fieldResult = field.getDescribe();   
                if(fieldResult.isAccessible()){
                    allFieldsOfObject.add(fieldResult.getName());
                }
            }
        }
        return allFieldsOfObject;
    }
    
    /*================================================
      *@description : The method returns all the records of the selectedObject and selected list of columns 
						in the form of a concatenated comma separated string
	   @param : selectedObject - API Name of the Selected object for which the records need to be downloaded
	   @param : selectedColumns - List of columns to retrieve data from. If the list contains 'All', all the columns (standard/custom) will be considered
      *@return : String
     ================================================*/
    @AuraEnabled
    public static String getRecords(String selectedObject, List<String> selectedColumns){
        if(selectedColumns != null && !selectedColumns.isEmpty()){
            if(selectedColumns.contains('All')){
                selectedColumns = getAllFieldsOfObject(selectedObject);
            }
            String cols = String.join(selectedColumns, ',');
            String strQuery = 'select '+cols+' from '+selectedObject;
            List<SObject> records = Database.query(strQuery);
            List<String> rows=new List<String>();
            rows.add(cols);
            for(SObject objRecord : records){
                String row = '';
                for(String strFieldName : selectedColumns){
                    String fieldValue = objRecord.get(strFieldName)==null ? '' : String.valueOf(objRecord.get(strFieldName));
                    if(selectedObject.equalsIgnoreCase('CRS_Verbatim__c') && strFieldName.equalsIgnoreCase('CRS_Verbatim_Text__c') || 
                      selectedObject.equalsIgnoreCase('CRS_Verification_Details__c') && strFieldName.equalsIgnoreCase('CRS_Session_Context__c')){
                        fieldValue = EncodingUtil.urlEncode(fieldValue,'UTF-8').replace('+',' ');
                    }
                    row = row+'"'+fieldValue+'",';
                }
                row = row.removeEnd(',');
                rows.add(row);
            }
            return String.join(rows, '\n');
        } else{
            return null;
        }
    }
    
    //Handler method to populate the field definitions for all the custom objects
    @AuraEnabled
    public static String getFieldDefinitionsForAllObjects(){
		List<String> rows = new List<String>();
        rows.add('"Object","Field","Label","Help","Type","Relathioship","Length","Scale","Precision","IsCustom","IsCalculated","IsEncrypted"');
        List<String> allObjects = getObjectOptions().values(); //Get list of all objects sorted by Object Labels
        List<String> customObjects = new List<String>();
        for(String objName : allObjects) {
            if(objName.endsWithIgnoreCase('__c')) { //Filter to get only the Custom Object names. Condition can change as per requirements.
                customObjects.add(objName);
            }
        }
        rows.addAll(getFieldDescriptionsForSObject(customObjects));
        return String.join(rows, '\n');
    }
    
    @AuraEnabled
    public static String getFieldDefinitionsForSelectedObjects(List<String> selectedObjects){
        List<String> rows = new List<String>();
        rows.add('"Object","Field","Label","Help","Type","Relathioship","Length","Scale","Precision","IsCustom","IsCalculated","IsEncrypted"');
        rows.addAll(getFieldDescriptionsForSObject(selectedObjects));
        return String.join(rows, '\n');
    }
    
    
    //Populate field descriptions for all sObjects belonging to the mentioned category
    private static List<String> getFieldDescriptionsForSObject(List<String> sObjNames){
        List<String> lstDescriptions = new List<String>();
        for(String sObjName:sObjNames){
            Map<String,Schema.SObjectField> fieldMap = null;
            try{
                fieldMap = Schema.getGlobalDescribe().get(sObjName).
                    		getDescribe().fields.getMap();
            } catch(Exception e){
                //The Object Information not found. Skip to the Next object in the list
                continue;
            }
            for(Schema.SObjectField field : fieldMap.values()){
                Schema.DescribeFieldResult fieldResult = field.getDescribe();   
                String row = sObjName+',"'
                    +fieldResult.getName()+'","'
                    +fieldResult.getLabel()+'","'
                    +(fieldResult.getInlineHelpText()==null?'':fieldResult.getInlineHelpText())+'","'
                    +fieldResult.getType()+'","'
                    +(fieldResult.getRelationshipName()==null?'':fieldResult.getRelationshipName())+'","'
                    +fieldResult.getLength()+'","'
                    +fieldResult.getScale()+'","'
                    +fieldResult.getPrecision()+'","'
                    +fieldResult.isCustom()+'","'
                    +fieldResult.isCalculated()+'","'
                    +fieldResult.isEncrypted()+'"';
                lstDescriptions.add(row);
            }
        }
        return lstDescriptions;
    }
}