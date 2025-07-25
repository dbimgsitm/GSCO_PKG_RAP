@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'GL평가클래스 Interface View'
@VDM.viewType: #BASIC
@ObjectModel.usageType.serviceQuality: #A
@ObjectModel.usageType.sizeCategory: #S
@ObjectModel.usageType.dataClass: #MASTER
define root view entity ZI_MTMASTER_GL_DISTINCT
  as select distinct from ztgsco0032 as Main
  association [*] to ZI_MASTER_GL_H as _History on $projection.Id = _History.Refhead 
{
  key Main.id                     as Id,
      Main.companycode            as Companycode,
      Main.materialvaluationclass as Materialvaluationclass, 
      Main.classname              as Classname,
      Main.glaccount              as Glaccount,
      Main.glaccountname          as Glaccountname,
      
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
