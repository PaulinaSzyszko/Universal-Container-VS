/**
 * Created by SZYSZPA on 21-Feb-22.
 */

({
    checkRegionForSchedule: function (component) {
        let recordId = component.get('v.recordId');
        let getRegions = component.get("c.checkScheduleRegion");

        $A.enqueueAction(getRegions);
        getRegions.setParams({
            scheduleId: recordId
        });

        $A.get("e.force:closeQuickAction").fire();
        $A.get("e.force:refreshView").fire();
    }
});