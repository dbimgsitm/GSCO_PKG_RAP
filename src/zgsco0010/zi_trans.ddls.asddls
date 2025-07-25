@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '이동평균-합산sum'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZI_TRANS
  with parameters
    P_FromFiscalYearPeriod :fml_fyearperiod_from,
    P_ToFiscalYearPeriod   :fml_fyearperiod_to
  as select from I_TransBsdMatlValueChainItem(
                    P_FromFiscalYearPeriod : $parameters.P_FromFiscalYearPeriod,
                    P_ToFiscalYearPeriod   : $parameters.P_ToFiscalYearPeriod)
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
