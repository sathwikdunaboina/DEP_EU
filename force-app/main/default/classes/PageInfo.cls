public inherited sharing class PageInfo {
 	@AuraEnabled
    public Integer currentPageNumber {get;set;}
    @AuraEnabled
    public Integer totalPages {get;set;}
    @AuraEnabled
    public List<Integer> pageCounter {get;set;}
}