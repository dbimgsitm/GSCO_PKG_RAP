@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '수불부 자재원장 순번 History'
@VDM.viewType: #BASIC
@ObjectModel.usageType.serviceQuality: #A
@ObjectModel.usageType.sizeCategory: #S
@ObjectModel.usageType.dataClass: #MASTER
define root view entity ZI_MTCATESEG_H
  as select from ztgsco0050h
  association [0..*] to ZI_MTCATESEG as _Original on $projection.Refhead = _Original.Id
{
  key id                         as Id,
      refhead                    as Refhead,
      action                     as Action,
      sequence                   as Sequence,
      materialledgercategory     as Materialledgercategory,
      materialledgercategorytext as Materialledgercategorytext,
      @EndUserText: {
          label : '삭제 플래그',
          quickInfo: '삭제 플래그'
      }
      delete_flag                as DeleteFlag,
      @Semantics.user.createdBy: true
      @EndUserText: {
        label : '생성자',
        quickInfo: '생성자'
      }
      create_by                  as CreateBy,
      @Semantics.systemDateTime.createdAt: true
      @EndUserText: {
         label : '생성일시',
         quickInfo: '생성일시'
      }
      create_at                  as CreateAt,
      @Semantics.user.lastChangedBy: true
      @EndUserText: {
         label : '수정자',
         quickInfo: '수정자'
      }
      last_changed_by            as LastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      @EndUserText: {
         label : '수정일시',
         quickInfo: '수정일시'
      }
      last_changed_at            as LastChangedAt,
      
      //Association
      _Original
}
