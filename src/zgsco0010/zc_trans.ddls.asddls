@AccessControl.authorizationCheck: #NOT_REQUIRED
@AbapCatalog.viewEnhancementCategory: [#NONE]
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
@EndUserText.label: '이동평균-합산'
define root view entity ZC_TRANS
  with parameters
    P_FromFiscalYearPeriod :fml_fyearperiod_from,
    P_ToFiscalYearPeriod   :fml_fyearperiod_to
  as select distinct from I_TransBsdMatlValueChainItem(
                          P_FromFiscalYearPeriod : $parameters.P_FromFiscalYearPeriod,
                          P_ToFiscalYearPeriod   : $parameters.P_ToFiscalYearPeriod) as Main
  association [1..1] to ZI_GLMTMASTER as _GLMT        on $projection.Material = _GLMT.Product
  association [1..1] to I_ProductText as _ProductText on $projection.Material = _ProductText.Product
  association [0..1] to ZI_TRANS      as _Trans       on $projection.Material = _Trans.Material
{
  key Main.CostEstimate,
  key Main.CurrencyRole,
  key Main.Ledger,
  key Main.FiscalYearPeriod,
  key Main.MaterialLedgerCategory,
  key Main.ProcessCategory,
  key Main.MatlLdgrDocIsCostingRelevant,
  key Main.ProcurementAlternative,
  key Main.ProductionProcess,
  key Main.MovementType,
  key Main.GLAccount,
      $parameters.P_FromFiscalYearPeriod as InputFomFiscalYearPeriod,
      $parameters.P_ToFiscalYearPeriod   as InputToFisicalYearPeriod,
      _GLMT.MaterialvaluationClass       as MaterialValuationClass,
      _GLMT.ClassName,
      _GLMT.GLAccount                    as GLAccount_Class,
      _GLMT.GLAccountName                as GLAccountName_Class,
      _ProductText.ProductName           as ProductName,

      Main.PriceDeterminationControl,
      Main.ValuationArea,
      Main.Material,
      Main.InventoryValuationType,
      Main.SalesOrder,
      Main.SalesOrderItem,
      Main.InventorySpecialStockType,
      Main.Supplier,
      Main.WBSElementExternalID,
      Main.MaterialLedgerCategoryText,
      Main.ProcessCategoryName,
      Main.GoodsMovementTypeName,
      Main.GLAccountName,
      Main.InventorySpecialStockTypeName,
      Main.TotalVltdStockQuantity,
      Main.ValuationQuantityUnit,
      @Semantics.amount.currencyCode: 'Currency'
      Main.InventoryAmtInDspCrcy,
      Main.InvtryTransacAmtInDisplayCrcy,
      Main.PriceDiffAmtInDisplayCrcy,
      Main.ExchRateDiffAmtInDspCurrency,
      Main.Currency,
      Main.ControllingArea,
      Main.ControllingValuationType,
      @Semantics.amount.currencyCode: 'Currency'
      _Trans( P_FromFiscalYearPeriod: $parameters.P_FromFiscalYearPeriod , P_ToFiscalYearPeriod: $parameters.P_FromFiscalYearPeriod ).sum_inventory,

      /* Associations */
      Main._Currency,
      Main._Ledger,
      Main._Plant,
      Main._Product,
      Main._QuantityUnit
}
where
      Main.CurrencyRole     = '10'
  and Main.Ledger           = '0L'
  and _ProductText.Language = '3'
