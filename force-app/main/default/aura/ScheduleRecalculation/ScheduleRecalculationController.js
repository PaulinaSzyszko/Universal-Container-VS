/**
 * Created by SZYSZPA on 15-Feb-22.
 */

({
    getTotalsFromSchedules: function (component) {
        let recordId = component.get('v.recordId');
        let getTotals = component.get("c.refreshTotals");

        getTotals.setParams({
            scheduleId: recordId
        });

        $A.enqueueAction(getTotals);

        $A.get("e.force:closeQuickAction").fire();
        $A.get("e.force:refreshView").fire();
    }
});