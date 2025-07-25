@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'GL 기준정보 H Interface View'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZI_MASTER_GL_H
  as select from ztgsco0032h as History
  association [0..*] to ZI_MASTER_GL as _Main on $projection.Refhead = _Main.Id
{
      key History.id as Id,
      History.refhead as Refhead,
      History.action as Action,
      History.companycode as Companycode,
      History.materialvaluationclass as Materialvaluationclass,
      History.classname as Classname,
      History.glaccount as Glaccount,
      History.glaccountname as Glaccountname,
      History.delete_flag as DeleteFlag,
      @Semantics.user.createdBy: true
      History.create_by                 as CreateBy,
      @Semantics.systemDateTime.createdAt: true
      History.create_at                 as CreateAt,
      @Semantics.user.lastChangedBy: true
      History.last_changed_by           as LastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      History.last_changed_at           as LastChangedAt,

      //Association
      _Main
}
