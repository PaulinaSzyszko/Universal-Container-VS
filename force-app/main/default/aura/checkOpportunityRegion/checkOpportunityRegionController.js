/**
 * Created by SZYSZPA on 18-Feb-22.
 */

({
    checkOpportunityRegion: function (component) {
        let getRegions = component.get("c.checkRegion");
        let recordId = component.get('v.recordId');

        getRegions.setParams({
            opportunityId: recordId
        });

        $A.enqueueAction(getRegions);

        $A.get("e.force:closeQuickAction").fire();
        $A.get("e.force:refreshView").fire();
    }
});