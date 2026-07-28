@IsTest
public class PageInfoTest {
@IsTest    
static void testPageInfoProperties() {
       // Arrange7        
       PageInfo pageInfo = new PageInfo();
       pageInfo.currentPageNumber = 2;
       pageInfo.totalPages = 10;
       pageInfo.pageCounter = new List<Integer>{1, 2, 3, 4, 5};
       // Assert
       System.assertEquals(2, pageInfo.currentPageNumber,'Current page number should match the assigned value.');
       System.assertEquals(10, pageInfo.totalPages,'Total pages should match the assigned value.');
       System.assertEquals(5, pageInfo.pageCounter.size(),'Page counter should contain 5 entries.');
       System.assertEquals(new List<Integer>{1, 2, 3, 4, 5},pageInfo.pageCounter,'Page counter values should match.');
  }
}