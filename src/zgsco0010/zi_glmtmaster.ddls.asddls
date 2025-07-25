@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'GL평가클래스-자재 Interface View'
@VDM.viewType: #BASIC

@ObjectModel.usageType.serviceQuality: #A
@ObjectModel.usageType.sizeCategory: #S
@ObjectModel.usageType.dataClass: #MASTER

define root view entity ZI_GLMTMASTER
as select from ZI_GLMTMASTER_DISTINCT as Main
  association [0..*] to I_ProductValuationBasic as _Product on $projection.MaterialvaluationClass = _Product.ValuationClass
{
  key Main.Id,
      Main.MaterialvaluationClass,
      Main.ClassName,
      Main.GLAccount,
      Main.GLAccountName,
      
      _Product.Product,
      _Product.ValuationClass,
      
      Delete_Flag,      
      CreateBy,
      CreateAt,
      LastChangedBy,
      LastChangedAt,
      /* Associations */
      _History

} 
