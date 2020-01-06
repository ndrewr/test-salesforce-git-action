@isTest
public with sharing class testRandomStuff {
    static testMethod void testGetRandomNumber() {
        System.assert(randomStuff.getRandomNumber() == 7);
    }

    static testMethod void testGetRandomText(){
        String result = '';
        Test.startTest();
        result = randomStuff.getRandomText();
        Test.stopTest();
        System.assertEquals(result, 'Totally random.', 'Ruhroh! There was a problem with result of getRandomText!');
    }
}
