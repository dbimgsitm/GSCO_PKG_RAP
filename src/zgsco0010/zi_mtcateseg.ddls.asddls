@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '수불부 자재원장 순번 Interface View'
@VDM.viewType: #BASIC
@ObjectModel.usageType.serviceQuality: #A
@ObjectModel.usageType.sizeCategory: #S
@ObjectModel.usageType.dataClass: #MASTER
define root view entity ZI_MTCATESEG
  as select from ztgsco0050 as Main 
  association [*] to ZI_GLMTMASTER_H as _History on $projection.Id = _History.Refhead
{
  key Main.id                         as Id,
      Main.sequence                   as Sequence,
      Main.materialledgercategory     as Materialledgercategory,
      Main.materialledgercategorytext as Materialledgercategorytext,
      @EndUserText: {
          label : '삭제 플래그',
          quickInfo: '삭제 플래그'
      }
      Main.delete_flag                as DeleteFlag,
      @Semantics.user.createdBy: true
      @EndUserText: {
        label : '생성자',
        quickInfo: '생성자'
      }
      Main.create_by                  as CreateBy,
      @Semantics.systemDateTime.createdAt: true
      @EndUserText: {
         label : '생성일시',
         quickInfo: '생성일시'
      }
      Main.create_at                  as CreateAt,
      @Semantics.user.lastChangedBy: true
      @EndUserText: {
         label : '수정자',
         quickInfo: '수정자'
      }
      Main.last_changed_by            as LastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      @EndUserText: {
         label : '수정일시',
         quickInfo: '수정일시'
      }
      Main.last_changed_at            as LastChangedAt,

      //Association
      _History

}
