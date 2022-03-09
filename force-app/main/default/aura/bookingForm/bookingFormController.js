({
    init: function (component, event, helper) {
        component.set("v.Columns", [
            {label: "Name", fieldName: "name", type: "text"},
            {label: "Start Date", fieldName: "startDate", type: "text"},
            {label: "End Date", fieldName: "endDate", type: "text"},
            {label: "Route", fieldName: "route", type: "text"},
            {label: "Vessel", fieldName: "vessel", type: "text"}
        ]);
    },

    getSchedule: function (component, event, helper) {
        var getRoutesAction = component.get("c.getRoutes");

        getRoutesAction.setParams({

            startDate: !component.get("v.routeStartDate") ? null : component.get("v.routeStartDate"),
            endDate: !component.get("v.routeEndDate") ? null : component.get("v.routeEndDate"),
            departure: !component.get("v.departurePort") ? null : String(component.get("v.departurePort")),
            arrival: !component.get("v.arrivalPort") ? null : String(component.get("v.arrivalPort"))

        });
        console.log("start date: " + component.get("v.routeStartDate"));
        console.log("end date: " + component.get("v.routeEndDate"));
        console.log("departure: " + component.get("v.departurePort"));
        console.log("arrival: " + component.get("v.arrivalPort"));

        getRoutesAction.setCallback(this, function (data) {

            setTimeout(() => {
                console.log(data.getReturnValue())
                if (data.getReturnValue().length === 0) {
                    component.set("v.tableWithResults", false);
                    component.set("v.showMessage", true);
                    component.set("v.Routes", []);
                } else {
                    component.set("v.showMessage", false);
                    component.set("v.tableWithResults", true);
                    component.set("v.Routes", data.getReturnValue());
                }
                component.set("v.spinner", false);
            }, 500);
        });

        component.set("v.spinner", true);
        $A.enqueueAction(getRoutesAction);
    },

    onRouteSelected: function (component, event, helper) {

        let button = component.find('saveButton');
        button.set('v.disabled', false);
        component.set("v.bookingForm", true);
        component.set("v.selectedSchedule", event.getParam("selectedRows")[0].id);
    },

    handleClick: function (component, event, helper) {
        var toastEvent = $A.get("e.force:showToast");
        component.find('form').submit();
        toastEvent.setParams({
            title: "Schedule Booking",
            message: "Schedule booking has been successfully created",
            type: "success"
        });
        toastEvent.fire();

        // $A.get("e.force:refreshView").fire();
        $A.get("e.force:closeQuickAction").fire();
        $A.get("e.force:refreshView").fire();
    },

    cancel: function () {
        $A.get("e.force:closeQuickAction").fire();
    }

})