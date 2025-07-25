@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'GL 기준정보 Interface View'
@VDM.viewType: #BASIC

@ObjectModel.usageType.serviceQuality: #A
@ObjectModel.usageType.sizeCategory: #S
@ObjectModel.usageType.dataClass: #MASTER
define root view entity ZI_MASTER_GL
  as select from ZI_MTMASTER_GL_DISTINCT as Main
  association [0..*] to I_ProductValuationBasic as _Product on $projection.Materialvaluationclass = _Product.ValuationClass
{
  key Main.Id                     as Id,
      Main.Companycode            as Companycode, 
      Main.Materialvaluationclass as Materialvaluationclass, 
      Main.Classname              as Classname,
      Main.Glaccount              as Glaccount,
      Main.Glaccountname          as Glaccountname,
      
      _Product.Product,
      _Product.ValuationClass,
      
      Main.Delete_Flag,
      Main.CreateBy,
      Main.CreateAt,
      Main.LastChangedBy,
      Main.LastChangedAt,

      //Association
      _History,
      _Product
}
