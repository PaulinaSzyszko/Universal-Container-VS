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
        this.suppliedEmail = caseRecord.SuppliedEmail;
        this.suppliedPhone = caseRecord.SuppliedPhone;
        this.suppliedName = caseRecord.SuppliedName;
    }

    public String external_id { get; set; }
    public String preferred_language { get; set; }
    public String record_type { get; set; }
    public String priority { get; set; }
    public String origin { get; set; }
    public String subject { get; set; }
    public String description { get; set; }
    public String comments { get; set; }
    public String suppliedEmail { get; set; }
    public String suppliedPhone { get; set; }
    public String suppliedName { get; set; }
}
