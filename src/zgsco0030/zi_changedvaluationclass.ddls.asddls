@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '변경된평가클래스 관리'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZI_ChangedValuationClass
  as select from ztgsco0070 as Main
  association [*] to ZI_ChangedValuationClass_H as _History on $projection.Id = _History.Refhead

{
  key Main.id                     as Id,
      Main.companycode            as Companycode,
      Main.plant                  as Plant,
      Main.material               as Material,
      Main.validityenddate        as ValidityEndDate,
      Main.validitystartdate      as ValidityStartDate,
      Main.previousvaluationclass as PreviousValuationClass,
      Main.currentvaluationclass  as CurrentValuationClass,
      @EndUserText: {
          label : '삭제 플래그',
          quickInfo: '삭제 플래그'
      }
      Main.delete_flag            as DeleteFlag,
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
