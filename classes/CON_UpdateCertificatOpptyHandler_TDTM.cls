global class CON_UpdateCertificatOpptyHandler_TDTM extends hed.TDTM_Runnable {
   //global Static Map<ID, Set<ID>> mapMergedContactIdsByMasterId;
   // the Trigger Handler’s Run method we must provide
    global override hed.TDTM_Runnable.DmlWrapper run(List<SObject> newlist, List<SObject> oldlist,
        hed.TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {
        System.debug('Running CON_UpdateCertificatOpptyHandler_TDTM....');
        Set<String> contIdSet = new Set<String>();
        // if(triggerAction == hed.TDTM_Runnable.Action.BeforeInsert) {
        //     for(Contact cont : (list<Contact>)newlist) {
        //         if(cont.Program_Name__c != null && cont.Program_Name__c.containsIgnoreCase('ACG')) {
        //             contIdSet
        //         }
        //     }
        // }
        if(triggerAction == hed.TDTM_Runnable.Action.AfterUpdate) {
            Map<Id, Contact> oldContMap = new Map<Id, Contact>();
            for(Contact cont : (list<Contact>)oldlist) {
                oldContMap.put(cont.Id, cont);
            }
            Map<Id, Contact> contMap = new Map<Id, Contact>();
            for(Contact cont : (list<Contact>)newlist) {
                contMap.put(cont.Id, cont);
                Contact oldCont = oldContMap.get(cont.Id);
                if(cont.ACG_Interest_Adv_Certificate_in_Gov__c != oldCont.ACG_Interest_Adv_Certificate_in_Gov__c && cont.ACG_Interest_Adv_Certificate_in_Gov__c) {
                    contIdSet.add(cont.Id);
                }
                if(cont.CGM_Interest__c != oldCont.CGM_Interest__c && cont.CGM_Interest__c) {
                    contIdSet.add(cont.Id);
                }
                if(cont.OOC_Interest__c != oldCont.OOC_Interest__c && cont.OOC_Interest__c) {
                    contIdSet.add(cont.Id);
                }
            }

            List<Opportunity> opptyList = [Select Id, Primary_Contact__c, ACG_Interest__c, CGM_Interest__c, OOC_Interest__c From Opportunity Where Primary_Contact__c IN: contIdSet];
            for(Opportunity oppty : opptyList) {
                Contact cont = contMap.get(oppty.Primary_Contact__c);
                if(cont.ACG_Interest_Adv_Certificate_in_Gov__c) {
                    oppty.ACG_Interest__c = true;
                }
                if(cont.CGM_Interest__c) {
                    oppty.CGM_Interest__c = true;
                }
                if(cont.OOC_Interest__c) {
                    oppty.OOC_Interest__c = true;
                }
            }
            if(opptyList.size() > 0) {
                update opptyList;
            }
        }
        return null;
    }
}