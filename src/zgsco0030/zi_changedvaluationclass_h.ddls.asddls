@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '변경된평가클래스 관리 히스토리'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZI_ChangedValuationClass_H
  as select from ztgsco0070h as History
  association [0..*] to ZI_ChangedValuationClass as _Original on $projection.Refhead = _Original.Id
{
  key History.id                     as Id,
      History.refhead                as Refhead,
      History.action                 as Action,
      History.companycode            as Companycode,
      History.plant                  as Plant,
      History.material               as Material,
      History.validityenddate        as ValidityEndDate,
      History.validitystartdate      as ValidityStartDate,
      History.previousvaluationclass as PreviousValuationClass,
      History.currentvaluationclass  as CurrentValuationClass,
      @EndUserText: {
          label : '삭제 플래그',
          quickInfo: '삭제 플래그'
      }
      History.delete_flag            as DeleteFlag,
      @Semantics.user.createdBy: true
      @EndUserText: {
        label : '생성자',
        quickInfo: '생성자'
      }
      History.create_by              as CreateBy,
      @Semantics.systemDateTime.createdAt: true
      @EndUserText: {
         label : '생성일시',
         quickInfo: '생성일시'
      }
      History.create_at              as CreateAt,
      @Semantics.user.lastChangedBy: true
      @EndUserText: {
         label : '수정자',
         quickInfo: '수정자'
      }
      History.last_changed_by        as LastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      @EndUserText: {
         label : '수정일시',
         quickInfo: '수정일시'
      }
      History.last_changed_at        as LastChangedAt,

      //Association
      _Original
}
