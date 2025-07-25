@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '자재원장 기준정보 Interface View'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZI_MASTER_MATERIALTYPE
  as select from ztgsco0031 as Main
  association [*] to ZI_MASTER_MATERIALTYPE_H as _History on $projection.Id = _History.Refhead
{
  key id                        as Id,
      materialledgerprocesstype as Materialledgerprocesstype,
      typetext                  as Typetext,
      processcategory           as ProcessCategory,
      categorytext              as Categorytext,
      check_detailed            as CheckDetailed,
      delete_flag               as DeleteFlag,
      @Semantics.user.createdBy: true 
      create_by                 as CreateBy,
      @Semantics.systemDateTime.createdAt: true
      create_at                 as CreateAt,
      @Semantics.user.lastChangedBy: true
      last_changed_by           as LastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at           as LastChangedAt,

      //Association
      _History
}
