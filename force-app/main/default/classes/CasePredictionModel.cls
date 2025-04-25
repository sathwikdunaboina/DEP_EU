public class CasePredictionModel {
    
     // Convert status to numeric values
    public static Integer encodeStatus(String status) {
        if (status == 'New') return 0;
        if (status == 'InProgress') return 1;
        if (status == 'OnHold') return 2;
        if (status == 'Escalated') return 3;
        if (status == 'Duplicate') return 4;
        if (status == 'Closed') return 5;
        return -1; // Default in case of unknown status
    }

    // Convert owner to a numeric value (using hashCode for simplicity)
    public static Integer encodeOwner(Id ownerId) {
        return ownerId != null ? Math.abs(ownerId.hashCode()) / 1000 : 0;
        // Hashing owner ID to a number
    }

    // Convert priority to numeric values (assuming priority values like 'High', 'Medium', 'Low')
    public static Integer encodePriority(String priority) {
        if (priority == 'High') return 3;
        if (priority == 'Medium') return 2;
        if (priority == 'Low') return 1;
        return 0; // Default
    }

    // Convert IsEscalated (boolean) to numeric values: 1 for true, 0 for false
    public static Integer encodeEscalated(Boolean isEscalated) {
        return isEscalated ? 1 : 0;
    }
    
    // Train the model by calculating the coefficients (averages) for each feature
    public static void trainModel(List<Case> cases) {
        Decimal totalDaysOpen = 0;
        Decimal totalStatus = 0;
        Decimal totalOwner = 0;
        Decimal totalPriority = 0;
        Decimal totalEscalated = 0;
        Integer count = cases.size();

        // Iterate through all cases and calculate the sum of features
        for (Case c : cases) {
            // Calculate days open
           // DateTime createdDate = c.CreatedDate;
           // DateTime closeDate = c.ClosedDate != null ? c.ClosedDate : Date.today();
            //Integer daysOpen = closeDate.daysBetween(createdDate);

            
              Date createdDate =c.CreatedDate.date();
            Date closeDate;
              if(c.IsClosed)
              {
                    closeDate=c.ClosedDate.date();
              }
            else {
                closeDate= Date.today();
            }
              //Date closeDate = c.ClosedDate.date() != null ? c.ClosedDate.date() : Date.today();
           Integer daysOpen = createdDate.daysBetween(closeDate);
            // Sum up feature values
            totalDaysOpen += daysOpen;
            totalStatus += encodeStatus(c.Status);
            totalOwner += encodeOwner(c.OwnerId);
            totalPriority += encodePriority(c.Priority);
            totalEscalated += encodeEscalated(c.IsEscalated);
            
            
            
          
        }

        // Calculate the average (coefficient) for each feature
        Decimal coefStatus = totalStatus / count;
        Decimal coefOwner = totalOwner / count;
        Decimal coefPriority = totalPriority / count;
        Decimal coefEscalated = totalEscalated / count;
        Decimal intercept = totalDaysOpen / count;
        System.debug('These are totay days count'+totalDaysOpen);
        
        System.debug('These are model coefficients'+coefStatus);
         System.debug('These are model coefficients'+coefOwner);
         System.debug('These are model coefficients'+coefPriority);
         System.debug('These are model coefficients'+coefEscalated);
         System.debug('These are model coefficients'+intercept);
        

        // Store the model's coefficients (for reuse in predictions)
    
    }

    // Predict the Close Date using the trained model's coefficients
   /* public static Date predictCloseDate(Case c) {
        // Retrieve the model weights (coefficients) stored in a custom object
        CasePredictionModel__c model = [SELECT Coefficient_Status__c, Coefficient_Owner__c, Coefficient_Priority__c, Coefficient_Escalated__c, Intercept__c FROM CasePredictionModel__c LIMIT 1];

        // Encode the case features into numerical values
        Integer encodedStatus = encodeStatus(c.Status);
        Integer encodedOwner = encodeOwner(c.OwnerId);
        Integer encodedPriority = encodePriority(c.Priority);
        Integer encodedEscalated = encodeEscalated(c.IsEscalated == 'true');

        // Calculate the predicted number of days the case is open using the regression formula
        Decimal predictedDaysOpen = model.Intercept__c +
                                    (model.Coefficient_Status__c * encodedStatus) +
                                    (model.Coefficient_Owner__c * encodedOwner) +
                                    (model.Coefficient_Priority__c * encodedPriority) +
                                    (model.Coefficient_Escalated__c * encodedEscalated);
        
        // Predict the close date by adding predicted days to the case's created date
        Date predictedCloseDate = c.CreatedDate.addDays(Integer.valueOf(predictedDaysOpen));
        
        return predictedCloseDate;
    }*/
}