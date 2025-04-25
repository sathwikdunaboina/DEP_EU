/*
* -----------------------------------------------------------------------------------------
* Apex Class Name     CLA_GuidGenerator
* @author             Sourabh Sharma <sourabh.sharma@consultant.volvo.com>
* @Created Date       05-20-2024 
* @Used By            CLA_CreditLineConsumptionTriggerHandler,CLA_CreditLineControlTriggerHandler,CLA_CreditLineTriggerHandler  
* @Test Covered By    CLA_CreditLineConsumptionService_Test/CLA_CreditLineControlsServide_Test/CLA_CreditLineService_Test
* @SystemLayer        
* ------------------------------------------------------------------------------------------
* @description        This class is used for generating global unique idenitifier
* ------------------------------------------------------------------------------------------
*/ 
public with sharing class CLA_GuidGenerator {


/*
* ------------------------------------------------------------------------------------------------------
* @Method Name     generateGUID
* @description     Generate glbal unique identifier
* ------------------------------------------------------------------------------------------------------
* @param          
* @return         String     Returns global unique identifier  
* ------------------------------------------------------------------------------------------------------ 
*/ 

public static String generateGUID(){
        Blob key = Crypto.GenerateAESKey(128);
        String sKey = EncodingUtil.ConvertTohex(key);
        String sGuid = sKey.SubString(0,8)+ '-' + sKey.SubString(8,12) + '-' + sKey.SubString(12,16) + '-' + sKey.SubString(16,20) + '-' + sKey.substring(20);

        return sGuid;
       }
}