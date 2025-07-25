@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'GL 기준정보 Projection View'
@Search.searchable: true
@UI: {
    headerInfo: {
        typeName: 'GL-평가클래스',
        typeNamePlural: 'GL-평가클래스',
        title: { type: #STANDARD, value: 'Materialvaluationclass' },
        description: { type: #STANDARD, value: 'Classname' }
    },
    presentationVariant: [{
     sortOrder: [{ by: 'Glaccount', direction: #ASC }],
     visualizations: [{type: #AS_LINEITEM}]
    }]
}
define root view entity ZC_MASTER_GL
  provider contract transactional_query
  as projection on ZI_MTMASTER_GL_DISTINCT
{
      @UI.facet: [
       {
          id: 'Header',
          purpose: #HEADER,
          type: #FIELDGROUP_REFERENCE,
          targetQualifier: 'FIELD_HEADER'
       },
       {
          id: 'Item',
          label: 'GL-평가클래스',
          purpose: #STANDARD,
          type: #FIELDGROUP_REFERENCE,
          targetQualifier: 'FIELD_INFO'
       }
      ]

      @UI.hidden: true
  key Id,
      @UI: {
          lineItem: [{ position: 10, label:'회사코드', importance: #HIGH } ],
          fieldGroup: [
            { position: 10, qualifier: 'FIELD_INFO', label:'회사코드' }
          ],
          selectionField: [{ position: 10 }]
        }
      @Consumption.valueHelpDefinition: [{
        entity : {name : 'I_COMPANYCODESTDVH', element : 'CompanyCode'}
      }]
      @EndUserText : {
        label: '회사코드',
        quickInfo: '회사코드'
      }
      Companycode,
      @UI: {
          lineItem: [{ position: 20, label:'평가클래스', importance: #HIGH } ],
          fieldGroup: [
            { position: 20, qualifier: 'FIELD_HEADER', label:'평가클래스' },
            { position: 20, qualifier: 'FIELD_INFO', label:'평가클래스' }
          ],
          selectionField: [{ position: 20 }]
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
      Materialvaluationclass,
      @UI: {
          lineItem: [{ position: 30, label:'평가클래스명', importance: #HIGH } ],
          fieldGroup: [
            { position: 30, qualifier: 'FIELD_INFO', label:'평가클래스명' }
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
      Classname,
      @UI: {
          lineItem: [{ position: 40, label:'G/L계정', importance: #HIGH } ],
          fieldGroup: [
            { position: 40, qualifier: 'FIELD_HEADER', label:'G/L계정' },
            { position: 40, qualifier: 'FIELD_INFO', label:'G/L계정' }
          ],        
          selectionField: [{ position: 20 }]
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
      Glaccount,
      @UI: {
          lineItem: [{ position: 50, label:'G/L계정명', importance: #HIGH } ],
          fieldGroup: [
            { position: 50, qualifier: 'FIELD_INFO', label:'G/L계정명' }
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
      Glaccountname
}
where
  Delete_Flag != 'X'
