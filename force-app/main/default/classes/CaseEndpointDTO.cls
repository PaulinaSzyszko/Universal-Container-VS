public with sharing class CaseEndpointDTO {

    public CaseEndpointDTO(Case caseRecord) {

        this.external_id = caseRecord.External_Id__c;
        this.preferred_language = caseRecord.Preferred_Language__c;
        this.record_type = caseRecord.RecordType.DeveloperName;
        this.priority = caseRecord.Priority;
        this.origin = caseRecord.Origin;
        this.subject = caseRecord.Subject;
        this.description = caseRecord.Description;
        this.comments = caseRecord.Comments;
        this.supplied_email = caseRecord.SuppliedEmail;
        this.supplied_phone = caseRecord.SuppliedPhone;
        this.supplied_name = caseRecord.SuppliedName;
        this.last_change_source_org = caseRecord.Last_Change_Org_Id__c;
    }

    public String external_id { get; set; }
    public String preferred_language { get; set; }
    public String record_type { get; set; }
    public String priority { get; set; }
    public String origin { get; set; }
    public String subject { get; set; }
    public String description { get; set; }
    public String comments { get; set; }
    public String supplied_email { get; set; }
    public String supplied_phone { get; set; }
    public String supplied_name { get; set; }
    public String last_change_source_org { get; set; }
}
