@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '입출고 기준정보 Interface View'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZI_MASTER_INOUTTYPE
  as select from ztgsco0030 as Main
  association [*] to ZI_MASTER_INOUTTYPE_H as _History on $projection.Id = _History.Refhead
{
  key Main.id                        as Id,
      Main.companycode               as Companycode,
      Main.materialledgerprocesstype as Materialledgerprocesstype,
      Main.typetext                  as Typetext,
      Main.delete_flag               as DeleteFlag,
      @Semantics.user.createdBy: true
      Main.create_by                 as CreateBy,
      @Semantics.systemDateTime.createdAt: true
      Main.create_at                 as CreateAt,
      @Semantics.user.lastChangedBy: true
      Main.last_changed_by           as LastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      Main.last_changed_at           as LastChangedAt,
      
      //Association
      _History
      
}
