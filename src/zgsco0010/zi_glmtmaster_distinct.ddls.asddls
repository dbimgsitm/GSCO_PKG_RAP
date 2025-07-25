@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'GL평가클래스 Interface View'
@VDM.viewType: #BASIC
@ObjectModel.usageType.serviceQuality: #A
@ObjectModel.usageType.sizeCategory: #S
@ObjectModel.usageType.dataClass: #MASTER
define root view entity ZI_GLMTMASTER_DISTINCT
  as select distinct from ztgsco0040 as Main
  association [*] to ZI_GLMTMASTER_H as _History on $projection.Id = _History.Refhead
{
  key Main.id                     as Id,
      Main.materialvaluationclass as MaterialvaluationClass,
      Main.classname              as ClassName,
      Main.glaccount              as GLAccount,
      Main.glaccountname          as GLAccountName,
      
      @EndUserText: {
          label : '삭제 플래그',
          quickInfo: '삭제 플래그'
      }
      Main.delete_flag            as Delete_Flag,
      @Semantics.user.createdBy: true
      @EndUserText: {
        label : '생성자',
        quickInfo: '생성자'
      }
      Main.create_by              as CreateBy,
      @Semantics.systemDateTime.createdAt: true
      @EndUserText: {
         label : '생성일시',
         quickInfo: '생성일시'
      }
      Main.create_at              as CreateAt,
      @Semantics.user.lastChangedBy: true
      @EndUserText: {
         label : '수정자',
         quickInfo: '수정자'
      }
      Main.last_changed_by        as LastChangedBy,      
      @Semantics.systemDateTime.lastChangedAt: true
      @EndUserText: {
         label : '수정일시',
         quickInfo: '수정일시'
      }
      Main.last_changed_at        as LastChangedAt,
      
      //Association
      _History
} 
