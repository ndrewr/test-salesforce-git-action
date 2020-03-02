@isTest
public with sharing class testHeyPackageController {
    static testMethod void testGetRandomNumber() {
        System.assert(heyPackageController.getRandomNumber() == 7);
        // System.assert(heyPackageController.getRandomNumber() == 1);
    }

    static testMethod void testGetRandomText(){
        String result = '';
        Test.startTest();
        result = heyPackageController.getRandomText();
        Test.stopTest();
        System.assertEquals(result, 'Totally random.', 'Ruhroh! There was a problem with result of getRandomText!');
    }

    static testMethod void testGetRandomText2(){
        String result = '';
        Test.startTest();
        result = heyPackageController.getRandomText2();
        Test.stopTest();
        System.assertEquals(result, 'Totally more random.', 'Ruhroh! There was a problem with result of getRandomText!');
    }

}
