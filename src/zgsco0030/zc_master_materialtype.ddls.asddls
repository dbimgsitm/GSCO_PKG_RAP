@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '자재원장 기준정보 Projection View'
@Search.searchable: true
@UI: {
    headerInfo: {
        typeName: '자재원장범주',
        typeNamePlural: '자재원장범주',
        title: { type: #STANDARD, value: 'ProcessCategory' },
        description: { type: #STANDARD, value: 'Categorytext' }
    },
    presentationVariant: [{
     sortOrder: [{ by: 'ProcessCategory', direction: #ASC }],
     visualizations: [{type: #AS_LINEITEM}]
    }]
}
define root view entity ZC_MASTER_MATERIALTYPE
  provider contract transactional_query
  as projection on ZI_MASTER_MATERIALTYPE
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
          lineItem: [{ position: 10, label:'입출고타입', importance: #HIGH } ],
          fieldGroup: [
            { position: 10, qualifier: 'FIELD_HEADER', label:'입출고타입' },
            { position: 10, qualifier: 'FIELD_INFO', label:'입출고타입' }
          ],
          selectionField: [{ position: 10 }]
        }
      @Consumption.valueHelpDefinition: [{
        entity : {name : 'ZC_MASTER_INOUTTYPE', element : 'Materialledgerprocesstype'},
        additionalBinding: [{ element: 'Typetext',
                              localElement: 'Typetext',
                              usage: #RESULT }]
      }]
      @EndUserText : {
        label: '입출고타입',
        quickInfo: '입출고타입'
      }
      Materialledgerprocesstype,
      @UI: {
          lineItem: [{ position: 20, label:'입출고타입명', importance: #HIGH } ],
          fieldGroup: [
            { position: 20, qualifier: 'FIELD_HEADER', label:'입출고타입명' },
            { position: 20, qualifier: 'FIELD_INFO', label:'입출고타입명' }
          ],
          selectionField: [{ position: 20 }]
        }
      @EndUserText : {
        label: '입출고타입명',
        quickInfo: '입출고타입명'
      }
      Typetext,
      @UI: {
          lineItem: [{ position: 30, label:'자재원장범주', importance: #HIGH } ],
          fieldGroup: [
            { position: 30, qualifier: 'FIELD_INFO', label:'자재원장범주' }
          ],
          selectionField: [{ position: 30 }]
        }
      @Search: {
        defaultSearchElement: true,
        fuzzinessThreshold: 0.7,
        ranking: #HIGH
      }
      @EndUserText : {
        label: '자재원장범주',
        quickInfo: '자재원장범주'
      }
      ProcessCategory,
      @UI: {
          lineItem: [{ position: 40, label:'자재원장범주명', importance: #HIGH } ],          
          fieldGroup: [
            { position: 40, qualifier: 'FIELD_INFO', label:'자재원장범주명' }
          ]
        }
      @Search: {
        defaultSearchElement: true,
        fuzzinessThreshold: 0.7,
        ranking: #HIGH
      }
      @EndUserText : {
        label: '자재원장범주명',
        quickInfo: '자재원장범주명'
      } 
      Categorytext,
      @UI: {
          lineItem: [{ position: 50, label:'상세표시여부', importance: #HIGH } ],          
          fieldGroup: [
            { position: 50, qualifier: 'FIELD_INFO', label:'상세표시여부' }
          ]
        }
      @EndUserText : {
        label: '상세표시여부',
        quickInfo: '상세표시여부'
      } 
      CheckDetailed
} where DeleteFlag != 'X'
