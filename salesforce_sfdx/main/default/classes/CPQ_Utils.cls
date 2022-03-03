/*****************************************************************
Name:  CPQ_Utilities
==================================================================
Purpose: Holds reusable resources for CPQ classes.
==================================================================
*****************************************************************/

public class CPQ_Utils {
    public static final String 	CACHE_NAMESPACE =  'local';
    public static final String 	CACHE_PARTITION_NAME =  'CPQDefaultPartition';
    public static final String 	CACHE_KEY_VALUE =  'cpqStringTranslationsMap';
    public static final String 	LINE_ITEMS_JSON_NODE =  'lineItems';
    public static final String 	PRODUCT_GROUPS_JSON_NODE =  'productGroups';
    public static final String 	CHILD_PRODUCTS_JSON_NODE =  'childProducts';
    public static final String 	ATTRIBUTE_DROPDOWN_TYPE =  'Dropdown';

    /*****************************************************************
    Method Name: doTranslations
    Method Description: Translations for Product Name and Attributes
    *****************************************************************/
    public static void doTranslations(vlocity_cmt.JSONResult result){
        String namespace = CACHE_NAMESPACE;
        String partName = CACHE_PARTITION_NAME;
        Cache.OrgPartition orgCPQPart = Cache.Org.getPartition(namespace+'.'+partName);
        Map<String,Object> mapStringTranslation = new Map<String,Object>();

        if(orgCPQPart != null && orgCPQPart.contains(CACHE_KEY_VALUE)){
            mapStringTranslation = (Map<String,Object>)JSON.deserializeUntyped((String)orgCPQPart.get(CACHE_KEY_VALUE));
        }
        else{
            List<vlocity_cmt__StringTranslation__c> stringTranslationsList = [SELECT vlocity_cmt__StringId__r.Name, vlocity_cmt__Translation__c 
                FROM vlocity_cmt__StringTranslation__c
                WHERE vlocity_cmt__LocaleCode__c =: UserInfo.getLocale() AND vlocity_cmt__IsTranslated__c = true
            ];
    
            for(vlocity_cmt__StringTranslation__c translationRecord : stringTranslationsList){
                mapStringTranslation.put(translationRecord.vlocity_cmt__StringId__r.Name,translationRecord.vlocity_cmt__Translation__c);
            }
            orgCPQPart.put(CACHE_KEY_VALUE, JSON.serialize(mapStringTranslation));
        }

        for(vlocity_cmt.JSONRecord rec : result.records) {
            if(rec.fields.containsKey('name') && mapStringTranslation.containsKey((String)rec.fields.get('name'))){
                rec.fields.put('Name',(String)mapStringTranslation.get((String)rec.fields.get('name')));
            }

            if(rec.nameResult != null && (rec.nameResult).containsKey(ATTRIBUTE_CATEGORIES)){
                doTranslationAttributes(mapStringTranslation,rec.nameResult.get(ATTRIBUTE_CATEGORIES).records);
            }

            if(rec.nameResult != null && (rec.nameResult).containsKey(LINE_ITEMS_JSON_NODE)){
                doTranslationRecursive(mapStringTranslation, rec.nameResult.get(LINE_ITEMS_JSON_NODE).records);
            }

            if(rec.nameResult != null && (rec.nameResult).containsKey(PRODUCT_GROUPS_JSON_NODE)){
                doTranslationRecursive(mapStringTranslation, rec.nameResult.get(PRODUCT_GROUPS_JSON_NODE).records);
            }

            if(rec.nameResult != null && (rec.nameResult).containsKey(CHILD_PRODUCTS_JSON_NODE)){
                doTranslationRecursive(mapStringTranslation, rec.nameResult.get(CHILD_PRODUCTS_JSON_NODE).records);
            }
        }
    }

    /*****************************************************************
    Method Name: doTranslationRecursive
    Method Description: Recursive Translations for Bundle Offers with more than 1 hierarchy level
    *****************************************************************/
    private static void doTranslationRecursive(Map<String,Object> mapStringTranslation, List<vlocity_cmt.JSONRecord> xItems){
        if(xItems.size() > 0){
            for(vlocity_cmt.JSONRecord rec : xItems){
                if(rec.fields.containsKey('name') && mapStringTranslation.containsKey((String)rec.fields.get('name'))){
                    rec.fields.put('Name',(String)mapStringTranslation.get((String)rec.fields.get('name')));
                }

                if(rec.nameResult != null && (rec.nameResult).containsKey(ATTRIBUTE_CATEGORIES)){
                    doTranslationAttributes(mapStringTranslation,rec.nameResult.get(ATTRIBUTE_CATEGORIES).records);
                }

                if(rec.nameResult != null && (rec.nameResult).containsKey(LINE_ITEMS_JSON_NODE)){
                    doTranslationRecursive(mapStringTranslation, rec.nameResult.get(LINE_ITEMS_JSON_NODE).records);
                }

                if(rec.nameResult != null && (rec.nameResult).containsKey(PRODUCT_GROUPS_JSON_NODE)){
                    doTranslationRecursive(mapStringTranslation, rec.nameResult.get(PRODUCT_GROUPS_JSON_NODE).records);
                }
    
                if(rec.nameResult != null && (rec.nameResult).containsKey(CHILD_PRODUCTS_JSON_NODE)){
                    doTranslationRecursive(mapStringTranslation, rec.nameResult.get(CHILD_PRODUCTS_JSON_NODE).records);
                }
            }
        }
    }

    /*****************************************************************
    Method Name: doTranslationAttributes
    Method Description: Attribute Translations (Attribute Labels and Attributes Dropdown Values)
    *****************************************************************/
    private static void doTranslationAttributes(Map<String,Object> mapStringTranslation, List<vlocity_cmt.JSONRecord> attributesCategoriesList){
        for (vlocity_cmt.JSONRecord attributesCategory : attributesCategoriesList) {    
            List<vlocity_cmt.JSONRecord> attributesList = attributesCategory.nameResult.get(PRODUCT_ATTRIBUTES).records;

            for (vlocity_cmt.JSONRecord attribute : attributesList) {
                vlocity_cmt.JSONAttribute a = (vlocity_cmt.JSONAttribute) attribute;
                if(mapStringTranslation.containsKey(a.label)){
                    a.label = (String)mapStringTranslation.get(a.label);
                    if(a.inputType == ATTRIBUTE_DROPDOWN_TYPE){
                        for(vlocity_cmt.JSONAttribute.JSONValue attrValue : a.values){
                            if(mapStringTranslation.containsKey(attrValue.label)){
                                attrValue.label = (String)mapStringTranslation.get(attrValue.label);
                            }
                        }
                    }
                }
            }
        }
    }
}
