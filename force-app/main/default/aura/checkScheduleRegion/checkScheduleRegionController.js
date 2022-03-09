/**
 * Created by SZYSZPA on 18-Feb-22.
 */
({
    checkRegionForSchedule: function (component) {
        let getRegions = component.get("c.checkScheduleRegion");

        $A.enqueueAction(getRegions);

        $A.get("e.force:closeQuickAction").fire();
        $A.get("e.force:refreshView").fire();
    }
});