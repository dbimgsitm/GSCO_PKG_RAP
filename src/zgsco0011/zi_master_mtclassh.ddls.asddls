@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '평가클래스 타입 History Interface View'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZI_MASTER_MTCLASSH
  as select from ztgsco0060h
  association [0..*] to ZI_MASTER_MTCLASS as _Original on $projection.Refhead = _Original.Id

{
  key id              as Id,
      refhead         as Refhead,
      action          as Action,
      account         as Account,
      materialclass   as Materialclass,
      materialtype    as Materialtype,
      @EndUserText: {
          label : '삭제 플래그',
          quickInfo: '삭제 플래그'
      }
      delete_flag     as Delete_Flag,
      @Semantics.user.createdBy: true
      @EndUserText: {
        label : '생성자',
        quickInfo: '생성자'
      }
      create_by       as CreateBy,
      @Semantics.systemDateTime.createdAt: true
      @EndUserText: {
         label : '생성일시',
         quickInfo: '생성일시'
      }
      create_at       as CreateAt,
      @Semantics.user.lastChangedBy: true
      @EndUserText: {
         label : '수정자',
         quickInfo: '수정자'
      }
      last_changed_by as LastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      @EndUserText: {
         label : '수정일시',
         quickInfo: '수정일시'
      }
      last_changed_at as LastChangedAt,

      //Association
      _Original
}
