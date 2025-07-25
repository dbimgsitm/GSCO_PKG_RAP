@AccessControl.authorizationCheck: #NOT_REQUIRED
@AbapCatalog.viewEnhancementCategory: [#NONE]
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
@EndUserText.label: '실제원가 수불부'
define root view entity ZC_ACTLCOST_V3
  with parameters
    P_CostingRunType : ckml_run_type,
    P_FiscalPeriod   : fins_fiscalperiod,
    P_FiscalYear     : fis_gjahr_no_conv
  as select from I_ActlCostgMatlValueChainItem(
                 P_CostingRunType : $parameters.P_CostingRunType,
                 P_FiscalPeriod   : $parameters.P_FiscalPeriod,
                 P_FiscalYear     : $parameters.P_FiscalYear ) as Main
  association [1..1] to ZI_MASTER_GL as _GLMT        on $projection.Material = _GLMT.Product 
  association [1..1] to I_ProductText      as _ProductText on $projection.Material = _ProductText.Product
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


      $parameters.P_CostingRunType as InputCostingRunType,
      $parameters.P_FiscalPeriod   as InputFiscalPeriod,
      $parameters.P_FiscalYear     as InputFiscalYear,

      _GLMT.Materialvaluationclass as MaterialValuationClass,
      _GLMT.Classname,
      _GLMT.Glaccount              as GLAccount_Class,
      _GLMT.Glaccountname          as GLAccountName_Class,
      _ProductText.ProductName     as ProductName,

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
