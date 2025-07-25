@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '실제원가-합산sum'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZI_ACTL
  with parameters
    P_CostingRunType : ckml_run_type,
    P_FiscalPeriod   : fins_fiscalperiod,
    P_FiscalYear     : fis_gjahr_no_conv
  as select from I_ActlCostgMatlValueChainItem(
                 P_CostingRunType : $parameters.P_CostingRunType,
                 P_FiscalPeriod   : $parameters.P_FiscalPeriod,
                 P_FiscalYear     : $parameters.P_FiscalYear )
{

  key Material,
      Currency,
      @Semantics.amount.currencyCode: 'Currency'
      cast (sum(
        case MaterialLedgerCategory
            when 'AB' then cast(InventoryAmtInDspCrcy as abap.dec(15,2))
            when 'ZU' then cast(InventoryAmtInDspCrcy as abap.dec(15,2))
            when 'ND' then cast(InventoryAmtInDspCrcy as abap.dec(15,2))
            when 'VN' then -1 * cast(InventoryAmtInDspCrcy as abap.dec(15,2))
            when 'EB' then -1 * cast(InventoryAmtInDspCrcy as abap.dec(15,2))
            else 0
        end
       ) as abap.curr(15,2) ) as sum_inventory
}
where
      CurrencyRole = '10'
  and Ledger       = '0L'
group by
  Material,
  Currency
