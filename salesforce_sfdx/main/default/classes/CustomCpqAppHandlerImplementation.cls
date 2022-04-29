global with sharing class CustomCpqAppHandlerHookImplementation implements vlocity_cmt.VlocityOpenInterface {
    
    global Boolean invokeMethod(String methodName, Map<String, Object> input, Map<String, Object> output, Map<String, Object> options) {
        try{            
            if(methodName == 'getCartsItems.PostInvoke'){
                CPQ_Utils.doTranslations((vlocity_cmt.JSONResult)output.get('result'));
                CPQ_Utils.doManipulateItems((vlocity_cmt.JSONResult)output.get('result'));
            }
            else if(methodName == 'postCartsItems.PostInvoke') {
                CPQ_Utils.doTranslations((vlocity_cmt.JSONResult)output.get('result'));
                CPQ_Utils.doManipulateItems((vlocity_cmt.JSONResult)output.get('result'));
            }
            return true;
        }
        catch (Exception ex){
            System.debug('EXCEPTION: CustomCpqAppHandlerHookImplementation -> invokeMethod --- MESSAGE:' + ex.getMessage() + ' STACK TRACE: ' + ex.getStackTraceString());
            throw ex;
        }
    }    
}