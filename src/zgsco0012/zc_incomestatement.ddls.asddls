@EndUserText.label: '손익계산서(수불연동) Custom Entity'
@ObjectModel: {
    query: {
        implementedBy: 'ABAP:ZCL_ISNODEGLCAL' 
    }
}
define custom entity ZC_IncomeStatement
{  
  key Subject                     : abap.char( 255 );

  key GlAccount                   : abap.char( 10 );

  key NodeID                      : abap.char( 50 );

  key ParentNodeID                : abap.char( 50 );

      GlAccountText               : abap.char( 255 );

      SubjectText                 : abap.char( 255 );

      @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
      AmountInCompanyCodeCurrency : abap.curr( 23, 2 );

      @Semantics.currencyCode     : true
      CompanyCodeCurrency         : abap.cuky( 5 );

      HierarchyLevel              : abap.numc( 6 );

      DrillState                  : abap.char( 10 );

      SortIndex                   : abap.int4;

      checkGL                     : abap_boolean;
      
      top                         : int4;

      P_TOYEAR                    : gjahr;

      P_TOMONTH                   : poper;

      P_RUNTYPE                   : ckml_run_type;

      P_COMPCD                    : bukrs;

      P_CHEKGL                    : abap_boolean;
}
