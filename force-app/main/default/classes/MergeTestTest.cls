@IsTest
private class MergeTestTest {

    @IsTest
    static void testMessages() {
        System.assertEquals('Feature A', MergeTest.getFeatureA());
       
    }
}