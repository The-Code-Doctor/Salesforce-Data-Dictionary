The Data Dictionary is a Salesforce In-ORG tool to dynamically retrieve the Data Schema or Data (records) in a very few clicks.

The tool is a combination of a Flow named Data Dictionary (API Name: DataDictionaryFlow), 2 Aura Components (DataDictionaryCmp and FieldDescriptionsCmp), an Apex controller (DataDictionaryController) and it's corresponding test class (DataDictionaryControllerTest)

A package.xml is included in the home directory that can be used to deploy the tool to your ORG easily using the below command
sfdx force:source:deploy -u <<Org Alis>> -x package.xml
  
Once deployed, just drag-drop the "Data Dictionary" flow anywhere of your choice (Home page, Record page, Custom pages/screens etc.) and we are all set to GO..
  
Happy Tooling.. :)
