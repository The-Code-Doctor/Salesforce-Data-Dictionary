@isTest
public class DataDictionaryControllerTest {
	
    private static final String profileName = 'System Administrator';
    private static final String objectName = 'Case';
    private static final User runUser = [select Id from User where Profile.Name=:profileName AND isActive=true LIMIT 1];
    
    private static testMethod void getObjectOptionsTest(){
        System.runAs(runUser){
            Map<String,String> result = DataDictionaryController.getObjectOptions();
            System.assert(result.size() > 0);
        }
    }
    
    private static testMethod void getObjOptionsForFDsTest(){
        System.runAs(runUser){
            Map<String,String> result = DataDictionaryController.getObjOptionsForFDs();
            System.assert(result.size() > 0);
        }
    }
    
    private static testMethod void getFieldOptionsTest(){
        System.runAs(runUser){
            Map<String,String> result = DataDictionaryController.getFieldOptions(objectName);
            System.assert(result.size() > 0);
        }
    }
    
    private static testMethod void getRecordsTest(){
        System.runAs(runUser){
            insert new Case(Subject='Test');
            String result = DataDictionaryController.getRecords(objectName,new List<String>{'All'});
            System.assertNotEquals(null, result);
        }
    }
    
    private static testMethod void getFieldDefinitionsForAllObjectsTest(){
        System.runAs(runUser){
            String result = DataDictionaryController.getFieldDefinitionsForAllObjects();
            System.assertNotEquals(null, result);
        }
    }
    
    private static testMethod void getFieldDefinitionsForSelectedObjectsTest(){
        System.runAs(runUser){
            String result = DataDictionaryController.getFieldDefinitionsForSelectedObjects(new List<String>{objectName, 'InvalidName'});
            System.assertNotEquals(null, result);
        }
    }
}