/* 
* -----------------------------------------------------------------------------------------
* Apex Class Name     RemoveRecordsBatchClassSchedular
* @author             Sugapriya Vanjiyappan <sugapriya.vanjiyappan@consultant.volvo.com>
* @Created Date       25-11-2025 
* ------------------------------------------------------------------------------------------
* @description        This class is to Schedule the Batch Class RemoveRecordsBatchClass
* ------------------------------------------------------------------------------------------
*/
public class RemoveRecordsBatchClassSchedular implements Schedulable {
    public void execute(SchedulableContext sc){
        RemoveRecordsBatchClass batch = new RemoveRecordsBatchClass();
        Database.executeBatch(batch, 2000);
    }
    
}