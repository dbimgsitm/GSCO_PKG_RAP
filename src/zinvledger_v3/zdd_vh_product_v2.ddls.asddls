@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'VH_PRODUCT'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZDD_VH_PRODUCT_V2
  as select from I_ProductText
{
  key Product, 
  key Language,
      ProductName,
      /* Associations */
      _Product
}
where
  Language = '3'
