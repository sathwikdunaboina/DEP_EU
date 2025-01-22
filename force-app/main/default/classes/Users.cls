public inherited sharing class Users{
    
    private List<User> users;
    private List<PermissionSetAssignment> permSetAssignments;
    private List<GroupMember> publicGroupMembers;
    
    public Users(List<user> varUsers){
        this.users = varUsers; 
    }
    
    public Users Create(){
        Insert this.users;
        return this;
    }
    
    public Users DeActivate(){
        for( User user : this.users){
            System.Debug('user >>'+user);
            user.IsActive = false;
        }
        Update this.users;
        return this;
    }
    
    public Users AssignPermissionSetsFromTemplate(Map<Id,User> mapOfTemplateUsersById){
        this.permSetAssignments = new List<PermissionSetAssignment>();        
        for(User u : this.users){
            System.Debug('user >>'+u);
            if(u.get('TemplateUserId__c')!=null){
                User templateUser = mapOfTemplateUsersById.get((Id)u.get('TemplateUserId__c'));
                for(PermissionSetAssignment psa : templateUser.PermissionSetAssignments){
                    System.Debug('psa >>'+psa); 
                    if(!psa.PermissionSet.IsOwnedByProfile){                   
                        PermissionSetAssignment psaCloned = psa.Clone(false,true,false,false); 
                        psaCloned.AssigneeId = u.Id;
                        this.permSetAssignments.add(psaCloned);
                    }
                }
            }
        }        
        return this;
    }
    
    public Users AssignPublicGroupAndQueueFromTemplate(Map<Id,User> mapOfTemplateUsersById){
        this.publicGroupMembers = new List<GroupMember>();
        Map<Id,List<GroupMember>> mapOfGroupMembersByTemplateUserId = new Map<Id,List<GroupMember>>();
        List <GroupMember> listOfGroupMember = new List<GroupMember>();
        listOfGroupMember = [SELECT GroupId,UserOrGroupId FROM GroupMember WHERE UserOrGroupId IN : mapOfTemplateUsersById.keyset()];
        if(listOfGroupMember.size()>0){
            for(GroupMember gm : listOfGroupMember){
                if(mapOfGroupMembersByTemplateUserId.get(gm.UserOrGroupId) == null){
                    mapOfGroupMembersByTemplateUserId.put(gm.UserOrGroupId,new List<GroupMember>());
                }
                mapOfGroupMembersByTemplateUserId.get(gm.UserOrGroupId).add(gm);
            }
            for(User u : this.users){
                for(GroupMember grpMem : mapOfGroupMembersByTemplateUserId.get((Id)u.get('TemplateUserId__c'))){
                    GroupMember grpMemCloned = grpMem.Clone(false,true,false,false); 
                    grpMemCloned.UserOrGroupId = u.Id;
                    this.publicGroupMembers.add(grpMemCloned);
                }
            }
        }
        return this;
    }
    
    public Users SaveAssignments(){
        List<sobject> assignments = new List<sobject>();
        if(this.permSetAssignments.size()>0){
            assignments.addAll(this.permSetAssignments);
            System.Debug('this.permSetAssignments >>'+this.permSetAssignments); 
        }
        if(this.publicGroupMembers.size()>0){
            assignments.addAll(this.publicGroupMembers);
            System.Debug('this.publicGroupMembers >>'+this.publicGroupMembers); 
        }
        if(assignments.size()>0){
            Insert assignments; 
            return this;
        }
        else{
            return null;
        }
    }
    
    public List<user> getUsers(){
        return this.users;
    }
    
}