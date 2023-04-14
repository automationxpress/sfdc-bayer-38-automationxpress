({
  
  hideUserEditPopUp: function(component, event, helper) {
    var navToObjectHome = $A.get("e.force:navigateToObjectHome");
    navToObjectHome.setParams({"scope": "User_Entry__c"});
    navToObjectHome.fire();
    $A.get('e.force:refreshView').fire();
  },
  
  handleSaveSuccess: function(component, event) {
    /*var navEvt = $A.get("e.force:navigateToSObject");
    navEvt.setParams({
      "recordId": event.getParam('recordId'),
      "slideDevName": "detail"
    });
    navEvt.fire();
    $A.get('e.force:refreshView').fire();*/
      
    var recordId = event.getParam('recordId');  
    window.parent.location = '/' + recordId;
    
  }
  
})