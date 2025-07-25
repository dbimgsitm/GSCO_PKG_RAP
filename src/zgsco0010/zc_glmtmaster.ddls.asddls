@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'GL평가클래스 Projection View'
@Search.searchable: true
@VDM.viewType: #CONSUMPTION
@UI: {
    headerInfo: {
        typeName: '계정별 평가클래스',                         
        typeNamePlural: '계정별 평가클래스',                    
        title: { type: #STANDARD, value: 'MaterialvaluationClass' },       
        description: { type: #STANDARD, value: 'ClassName' } 
    },
    presentationVariant: [{                               
     sortOrder: [{ by: 'GLAccount', direction: #ASC }],
     visualizations: [{type: #AS_LINEITEM}]               
    }]
}
define root view entity ZC_GLMTMASTER
  provider contract transactional_query
  as projection on ZI_GLMTMASTER_DISTINCT
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
          label: '계정별 평가클래스 정의_수불부',
          purpose: #STANDARD,                           
          type: #FIELDGROUP_REFERENCE,                 
          targetQualifier: 'FIELD_INFO'                
       }
      ]

      @UI.hidden: true
  key Id,
      @UI: {
            lineItem: [{ position: 10, label:'평가클래스', importance: #HIGH } ],
            fieldGroup: [
                { position: 10, qualifier: 'FIELD_HEADER', label:'평가클래스' },
                { position: 10, qualifier: 'FIELD_INFO', label:'평가클래스' }
            ],
            selectionField: [{ position: 10 }]          
          }
      @Search: {                                        
        defaultSearchElement: true,
        fuzzinessThreshold: 0.7,
        ranking: #HIGH
      }
      @EndUserText : {
        label: '평가클래스',
        quickInfo: '평가클래스'
      }
      MaterialvaluationClass,
      @UI: {
        lineItem: [{ position: 20, label:'평가클래스명', importance: #HIGH } ],
        fieldGroup: [
            { position: 20, qualifier: 'FIELD_HEADER', label:'평가클래스명' },
            { position: 20, qualifier: 'FIELD_INFO', label:'평가클래스명' }
        ]
      }
      @Search: {                                       
        defaultSearchElement: true,
        fuzzinessThreshold: 0.7,
        ranking: #HIGH
      }
      @EndUserText : {
        label: '평가클래스명',
        quickInfo: '평가클래스명'
      }
      ClassName,
      @UI: {
        lineItem: [{ position: 30, label:'GL계정', importance: #HIGH } ],
        fieldGroup: [                                   
            { position: 30, qualifier: 'FIELD_INFO', label:'GL계정' }
        ],
        selectionField: [{ position: 30 }]              
      }
      @Search: {                                        
        defaultSearchElement: true,
        fuzzinessThreshold: 0.7,
        ranking: #HIGH
      }
      @EndUserText : {
        label: 'G/L계정',
        quickInfo: 'G/L계정'
      }
      GLAccount,
      @UI: {
        lineItem: [{ position: 40, label:'계정명', importance: #HIGH } ],
        fieldGroup: [
            { position: 40, qualifier: 'FIELD_INFO', label:'계정명' }
        ]
      } 
      @Search: {                                        
        defaultSearchElement: true,
        fuzzinessThreshold: 0.7,
        ranking: #HIGH
      }
      @EndUserText : {
        label: 'G/L계정명',
        quickInfo: 'G/L계정명'
      }
      GLAccountName
} where Delete_Flag != 'X'
