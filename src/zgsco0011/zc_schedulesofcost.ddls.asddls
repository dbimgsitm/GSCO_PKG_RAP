@EndUserText.label: '제조원가명세서 Custom Entity'
@ObjectModel: {
    query: {
        implementedBy: 'ABAP:ZCL_NODEGLCAL'
    }
}
define custom entity ZC_SCHEDULESOFCOST
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

      DrillState                  : abap.char( 8 );

      SortIndex                   : abap.int4;

      checkGL                     : abap_boolean;

      P_TOYEAR                    : gjahr;

      P_TOMONTH                   : poper;

      P_RUNTYPE                   : ckml_run_type;

      P_COMPCD                    : bukrs;

      P_CHEKGL                    : abap_boolean;
}
