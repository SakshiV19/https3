({
    init: function (component) {
        component.set("v.loading", true);

        const getJobIds = component.get("c.getJobIds");
        getJobIds.setParams({
            recordId: component.get('v.recordId'),
            fieldApiName: component.get('v.jobExecutionField'),
        });

        getJobIds.setCallback(this, function (response) {
            const state = response.getState();

            if (state === "SUCCESS") {
                const jobIds = response.getReturnValue();
                component.set("v.jobExecutionIds", jobIds);
                component.set("v.hasJobs", Boolean(jobIds.length));
            } else if (state === "ERROR") {
                this.showErrors(component, response.getError());
            }
        });

        $A.enqueueAction(getJobIds);
        component.set("v.loading", false);
    },

    showErrors: function (component, errors) {
        let errorMessage;
        if (errors && errors[0] && errors[0].message) {
            errorMessage = errors[0].message;
        } else {
            errorMessage = $A.get("$Label.c.Unexpected_Error_Occurred");
        }
        component.set("v.errorMessage", errorMessage);
    },
})