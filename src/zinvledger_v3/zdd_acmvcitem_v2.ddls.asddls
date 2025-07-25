@AccessControl.authorizationCheck: #NOT_REQUIRED
@AbapCatalog.viewEnhancementCategory: [#NONE]
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
@EndUserText.label: '수불부 실제 원가계산'
define root view entity ZDD_ACMVCITEM_V2
  with parameters
    P_CostingRunType : ckml_run_type,
    P_FiscalPeriod   : fins_fiscalperiod,
    P_FiscalYear     : fis_gjahr_no_conv
  as select from I_ActlCostgMatlValueChainItem(
                 P_CostingRunType : $parameters.P_CostingRunType,
                 P_FiscalPeriod   : $parameters.P_FiscalPeriod,
                 P_FiscalYear     : $parameters.P_FiscalYear )
{
  key CostEstimate,
  key CurrencyRole,
  key Ledger,
  key FiscalYearPeriod,
  key MaterialLedgerCategory,
  key ProcessCategory,
  key MatlLdgrDocIsCostingRelevant,
  key ProcurementAlternative,
  key ProductionProcess,
  key MovementType,
  key GLAccount,

      $parameters.P_CostingRunType as InputCostingRunType,
      $parameters.P_FiscalPeriod   as InputFiscalPeriod,
      $parameters.P_FiscalYear     as InputFiscalYear,
      PriceDeterminationControl,
      ValuationArea,
      Material, 
      InventoryValuationType,
      SalesOrder,
      SalesOrderItem,
      InventorySpecialStockType,
      Supplier,
      WBSElementExternalID,
      MaterialLedgerCategoryText,
      ProcessCategoryName,
      GoodsMovementTypeName,
      GLAccountName,
      InventorySpecialStockTypeName,
      TotalVltdStockQuantity,
      ValuationQuantityUnit,
      InventoryAmtInDspCrcy,
      InvtryTransacAmtInDisplayCrcy,
      PriceDiffAmtInDisplayCrcy,
      ExchRateDiffAmtInDspCurrency,
      Currency,
      ControllingArea,
      ControllingValuationType,
      /* Associations */
      _Currency,
      _Ledger,
      _Plant,
      _Product,
      _QuantityUnit
}
