@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '변경된평가클래스 관리 Projection'
@Search.searchable: true
@VDM.viewType: #CONSUMPTION
@UI: {
    headerInfo: {
        typeName: '평가클래스 변경내역',
        typeNamePlural: '평가클래스 변경내역',
        title: { type: #STANDARD, value: 'Material' }
    },
    presentationVariant: [{
     sortOrder: [{ by: 'Material', direction: #ASC }],
     visualizations: [{type: #AS_LINEITEM}]
    }]
}
define root view entity ZC_ChangedValuationClass
  provider contract transactional_query
  as projection on ZI_ChangedValuationClass
{
      //상세 페이지 정의
      @UI.facet: [
       {
          id: 'ChangedValuationClassHeader',
          purpose: #HEADER,
          type: #FIELDGROUP_REFERENCE,
          targetQualifier: 'FIELD_HEADER'
       },
       {
          id: 'ChangedValuationClassDetail',
          label: '평가클래스변경관리',
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
            ]
          }
      @Search: {
        defaultSearchElement: true,
        fuzzinessThreshold: 0.7,
        ranking: #HIGH
      }
      @EndUserText : {
        label: '회사코드',
        quickInfo: '회사코드'
      }
      @Consumption.valueHelpDefinition: [{ 
        entity: {
            name: 'I_CompanyCodeStdVH',
            element: 'CompanyCode'
        }
      }]
      Companycode,
      @UI: {
        lineItem: [{ position: 20, label:'플랜트', importance: #HIGH } ],
        fieldGroup: [
            { position: 20, qualifier: 'FIELD_INFO', label:'플랜트' }
        ]
      }
      @Search: {
        defaultSearchElement: true,
        fuzzinessThreshold: 0.7,
        ranking: #HIGH
      }
      @EndUserText : {
        label: '플랜트',
        quickInfo: '플랜트'
      }
      @Consumption.valueHelpDefinition: [{  
        entity: {
            name: 'I_PlantStdVH',
            element: 'Plant'
        }
      }]
      Plant,
      @UI: {
        lineItem: [{ position: 30, label:'자재', importance: #HIGH } ],
        fieldGroup: [
            { position: 30, qualifier: 'FIELD_HEADER', label:'자재' },
            { position: 30, qualifier: 'FIELD_INFO', label:'자재' }
        ],
            selectionField: [{ position: 10 }]
      }
      @Search: {
        defaultSearchElement: true,
        fuzzinessThreshold: 0.7,
        ranking: #HIGH
      }
      @EndUserText : {
        label: '자재',
        quickInfo: '자재'
      }
      Material,
      @UI: {
        lineItem: [{ position: 40, label:'효력종료기간', importance: #HIGH } ],
        fieldGroup: [
            { position: 40, qualifier: 'FIELD_INFO', label:'효력종료기간' }
        ]
      }
      @Search: {
        defaultSearchElement: true,
        fuzzinessThreshold: 0.7,
        ranking: #HIGH
      }
      @EndUserText : {
        label: '효력종료기간',
        quickInfo: '효력종료기간'
      }
      ValidityEndDate,
      @UI: {
        lineItem: [{ position: 50, label:'효력시작기간', importance: #HIGH } ],
        fieldGroup: [
            { position: 50, qualifier: 'FIELD_INFO', label:'효력시작기간' }
        ]
      }
      @Search: {
        defaultSearchElement: true,
        fuzzinessThreshold: 0.7,
        ranking: #HIGH
      }
      @EndUserText : {
        label: '효력시작기간',
        quickInfo: '효력시작기간'
      }
      ValidityStartDate,
      @UI: {
        lineItem: [{ position: 60, label:'이전평가클래스', importance: #HIGH } ],
        fieldGroup: [
            { position: 60, qualifier: 'FIELD_HEADER', label:'이전평가클래스' },
            { position: 60, qualifier: 'FIELD_INFO', label:'이전평가클래스' }
        ],
            selectionField: [{ position: 20 }]
      }
      @Search: {
        defaultSearchElement: true,
        fuzzinessThreshold: 0.7,
        ranking: #HIGH
      }
      @EndUserText : {
        label: '이전평가클래스',
        quickInfo: '이전평가클래스'
      }
      PreviousValuationClass,
      @UI: {
        lineItem: [{ position: 70, label:'현재평가클래스', importance: #HIGH } ],
        fieldGroup: [
            { position: 70, qualifier: 'FIELD_HEADER', label:'현재평가클래스' },
            { position: 70, qualifier: 'FIELD_INFO', label:'현재평가클래스' }
        ],
            selectionField: [{ position: 30 }]
      }
      @Search: {
        defaultSearchElement: true,
        fuzzinessThreshold: 0.7,
        ranking: #HIGH
      }
      @EndUserText : {
        label: '현재평가클래스',
        quickInfo: '현재평가클래스'
      }
      CurrentValuationClass,
      /* Associations */
      _History
}
where
  DeleteFlag != 'X'
