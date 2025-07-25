@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '자재원장 기준정보 H Interface View'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZI_MASTER_MATERIALTYPE_H
  as select from ztgsco0031h as History
  association [0..*] to ZI_MASTER_MATERIALTYPE as _Main on $projection.Refhead = _Main.Id
{
  key History.id                        as Id,
      History.refhead                   as Refhead,
      History.typetext                  as Typetext,
      History.action                    as Action, 
      History.materialledgerprocesstype as Materialledgerprocesstype,
      History.processcategory           as ProcessCategory,
      History.categorytext              as Categorytext,
      History.check_detailed            as CheckDetailed,
      History.delete_flag               as DeleteFlag,
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
