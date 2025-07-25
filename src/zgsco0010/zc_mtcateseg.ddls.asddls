@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '수불부 자재원장 순번 Projection View'
@Search.searchable: true
@UI: {
    headerInfo: {
        typeName: '자재원장 순번',                         
        typeNamePlural: '자재원장 순번',                    
        title: { type: #STANDARD, value: 'Sequence' },       
        description: { type: #STANDARD, value: 'Materialledgercategory' } 
    },
    presentationVariant: [{                               
     sortOrder: [{ by: 'Sequence', direction: #ASC }],
     visualizations: [{type: #AS_LINEITEM}]               
    }]
}
define root view entity ZC_MTCATESEG 
  provider contract transactional_query
  as projection on ZI_MTCATESEG
{
      //상세 페이지 정의
      @UI.facet: [
       {
          id: 'GLMaterialClassHeader',
          purpose: #HEADER,                             
          type: #FIELDGROUP_REFERENCE,                 
          targetQualifier: 'FIELD_HEADER'               
       },
       {
          id: 'GLMaterialClassDetail',
          label: '자재원장 순번',
          purpose: #STANDARD,                           
          type: #FIELDGROUP_REFERENCE,                 
          targetQualifier: 'FIELD_INFO'                
       }
      ]

      @UI.hidden: true
    key Id,
      @UI: {
            lineItem: [{ position: 10, label:'순번', importance: #HIGH } ],
            fieldGroup: [
                { position: 10, qualifier: 'FIELD_HEADER', label:'순번' },
                { position: 10, qualifier: 'FIELD_INFO', label:'순번' }
            ],
            selectionField: [{ position: 10 }]          
          }
      @Search: {                                        
        defaultSearchElement: true,
        fuzzinessThreshold: 0.7,
        ranking: #HIGH
      }
    Sequence,
      @UI: {
            lineItem: [{ position: 20, label:'자재원장', importance: #HIGH } ],
            fieldGroup: [
                { position: 20, qualifier: 'FIELD_HEADER', label:'자재원장' },
                { position: 20, qualifier: 'FIELD_INFO', label:'자재원장' }
            ],
            selectionField: [{ position: 20 }]          
          }
      @Search: {                                        
        defaultSearchElement: true,
        fuzzinessThreshold: 0.7,
        ranking: #HIGH
      }
    Materialledgercategory,
      @UI: {
        lineItem: [{ position: 30, label:'자재원장범주텍스트', importance: #HIGH } ],
        fieldGroup: [                                   
            { position: 30, qualifier: 'FIELD_INFO', label:'자재원장범주텍스트' }
        ],
        selectionField: [{ position: 30 }]              
      }
      @Search: {                                        
        defaultSearchElement: true,
        fuzzinessThreshold: 0.7,
        ranking: #HIGH
      }
    Materialledgercategorytext
} where DeleteFlag != 'X'
