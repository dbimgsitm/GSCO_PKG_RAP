 @AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'GL평가클래스 HS View'
define view entity ZI_GLMTMASTER_H
  as select from ztgsco0040h
  association [0..*] to  ZI_GLMTMASTER_DISTINCT as _Original on $projection.Refhead = _Original.Id
{
  key id                     as Id,
      refhead                as Refhead,
      action                 as Action,
      materialvaluationclass as MaterialvaluationClass,
      classname              as ClassName,
      glaccount              as GLAccount,
      glaccountname          as GLAccountName,
      @EndUserText: {
          label : '삭제 플래그',
          quickInfo: '삭제 플래그'
      }
      delete_flag            as Dlete_Flag,
      @Semantics.user.createdBy: true
      @EndUserText: {
        label : '생성자',
        quickInfo: '생성자'
      }
      create_by              as CreateBy,
      @Semantics.systemDateTime.createdAt: true
      @EndUserText: {
         label : '생성일시',
         quickInfo: '생성일시'
      }
      create_at              as CreateAt,
      @Semantics.user.lastChangedBy: true
      @EndUserText: {
         label : '수정자',
         quickInfo: '수정자'
      }
      last_changed_by        as LastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      @EndUserText: {
         label : '수정일시',
         quickInfo: '수정일시'
      }
      last_changed_at        as LastChangedAt,

      _Original
}
