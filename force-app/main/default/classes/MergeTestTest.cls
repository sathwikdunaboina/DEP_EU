@IsTest
private class MergeTestTest {

    @IsTest
    static void testGetMessage() {
        System.assertEquals('Feature B', MergeTest.getMessage());
    }
}