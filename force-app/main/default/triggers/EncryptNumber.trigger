trigger EncryptNumber on Opportunity (before insert, before update) {
    
    for(Opportunity opp : Trigger.new){
        // Generate your own initialization vector
        Blob iv = Blob.valueOf(opp.Quote_Id__c);
        
        // Generate an AES key
        Blob key = Crypto.generateAesKey(128);
        
        // Generate the data to be encrypted
        Blob data = Blob.valueof('Encrypt everything!');
        
        // Encrypt the data
        Blob encrypted = Crypto.encrypt('AES128', key, iv, data);
        opp.Quote_Id__c = encrypted.toString();
        // Decrypt the data
        Blob decrypted = Crypto.decrypt('AES256', key, iv, encrypted);
        
        // Decode the decrypted data
        String decryptedStringData = decrypted.toString();
    }
}