@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '평가클래스 타입 ValueHelp용'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZI_VHMTCLASSTYPE 
  as select from DDCDS_CUSTOMER_DOMAIN_VALUE_T( p_domain_name: 'ZDOGSCO0020' )
{
    @UI.hidden: true
    key domain_name,
    @UI.hidden: true
    key value_position,
    @UI.hidden: true
    key language,
    @EndUserText.label: '타입'
    value_low,
    @EndUserText.label: '텍스트'
    text
}
