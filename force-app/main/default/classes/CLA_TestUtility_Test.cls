/* 
* -----------------------------------------------------------------------------------------
* Apex Class Name     CLA_TestUtility_Test
* @author             Sourabh Sharma <sourabh.sharma@consultant.volvo.com> 
* @Created Date       05-17-2024         
* ------------------------------------------------------------------------------------------
* @description        Test class for CLA_TestUtility
* ------------------------------------------------------------------------------------------
*/
@isTest
private  class CLA_TestUtility_Test {

/*
* ------------------------------------------------------------------------------------------------------
* @Method Name     testGetTestResponse
* @description     This method test getTestResponse method.
* ------------------------------------------------------------------------------------------------------
* @param          
* @return          
* ------------------------------------------------------------------------------------------------------ 
*/
    
    @isTest
    private static void testGetTestResponse(){

        System.runAs(new User(Id = UserInfo.getUserId())){

        Test.startTest();
        RestResponse res = CLA_TestUtility.getTestResponse('test String','GET');
        Test.stopTest();
        System.assertEquals(null, res.statusCode, 'Expected status code is null.');
        
    }
        


    }

/*
* ------------------------------------------------------------------------------------------------------
* @Method Name     testGetTestResponse
* @description     This method test getTestResponse method.
* ------------------------------------------------------------------------------------------------------
* @param          
* @return          
* ------------------------------------------------------------------------------------------------------ 
*/
    

    @isTest
    private static void testgetTestResponsewithBody(){

        System.runAs(new User(Id = UserInfo.getUserId())){

        Test.startTest();
        RestResponse res =   CLA_TestUtility.getTestResponse('test String','GET','test body');
        Test.stopTest();
        System.assertEquals(null, res.statusCode, 'Expected status code is null.');

        }
        

    }
}