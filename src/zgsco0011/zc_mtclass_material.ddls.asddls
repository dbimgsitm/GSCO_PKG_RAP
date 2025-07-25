@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '평가클래스 타입 Projection View'
@Search.searchable: true
@UI: {
    headerInfo: {
        typeName: '계정별 평가클래스',
        typeNamePlural: '계정별 평가클래스',
        title: { type: #STANDARD, value: 'Account' }
    },
    presentationVariant: [{
     sortOrder: [{ by: 'Materialclass', direction: #ASC }],
     visualizations: [{type: #AS_LINEITEM}]
    }]
}
define root view entity ZC_MTCLASS_MATERIAL
  provider contract transactional_query
  as projection on ZI_MASTER_MTCLASS
{ 
      //상세 페이지 정의
      @UI.facet: [
       {
          id: 'MaterialClassHeader',
          purpose: #HEADER,                         
          type: #FIELDGROUP_REFERENCE,              
          targetQualifier: 'FIELD_HEADER'         
       },
       {
          id: 'MaterialClassDetail',
          label: '계정별 평가클래스 정의',
          purpose: #STANDARD,                      
          type: #FIELDGROUP_REFERENCE,              
          targetQualifier: 'FIELD_INFO'            
       }
      ]

      @UI.hidden: true
  key Id,
      @UI: { 
        lineItem: [{ position: 10, label:'계정명', importance: #HIGH } ],
        fieldGroup: [                               
            { position: 10, qualifier: 'FIELD_INFO', label:'계정명' }
        ],        
        selectionField: [{ position: 10 }]          
      }
      @Search: {                                   
        defaultSearchElement: true,
        fuzzinessThreshold: 0.7,
        ranking: #HIGH
      }
      Account,
      @UI: { 
        lineItem: [{ position: 20, label:'평가클래스', importance: #HIGH } ],
        fieldGroup: [
            { position: 10, qualifier: 'FIELD_HEADER', label:'평가클래스' },
            { position: 20, qualifier: 'FIELD_INFO', label:'평가클래스' }
        ],        
        selectionField: [{ position: 20 }]          
      }
      @Search: {                                    
        defaultSearchElement: true,
        fuzzinessThreshold: 0.7,
        ranking: #HIGH
      }      
      Materialclass,
      @UI: { 
        lineItem: [{ position: 30, label:'이동평균(V)/표준(S)', importance: #HIGH } ],
        fieldGroup: [                             
            { position: 30, qualifier: 'FIELD_INFO', label:'이동평균(V)/표준(S)' }
        ]
      }
      @Consumption.valueHelpDefinition: [{
        entity: { name : 'ZI_ReadDomainType', element: 'value_low'} 
      }]
      Materialtype,
      /* Associations */
      _History
} where Delete_Flag != 'X'
