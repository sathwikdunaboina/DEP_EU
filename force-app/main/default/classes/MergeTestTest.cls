@IsTest
private class MergeTestTest {
 
    @IsTest
    static void testMessages() {
        System.assertEquals('Feature B', MergeTest.getFeatureB());
    }
}