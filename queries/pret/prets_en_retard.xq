xquery version "3.1";

declare namespace db = "http://basex.org/modules/db";

declare variable $jours-retard-min external := "1";
declare variable $page external := 1;
declare variable $page-size external := 10;

let $prets := 
  db:get("isi_bibliotheque")/bibliotheque/prets/pret[
    statut = 'en cours' and
    current-date() > xs:date(dateRetourPrevue/text()) and
    days-from-duration(current-date() - xs:date(dateRetourPrevue/text())) >= xs:integer($jours-retard-min)
  ]
let $total := count($prets)
let $start := ($page - 1) * $page-size + 1
let $end := $page * $page-size

return
  <resultats jours-retard-min="{$jours-retard-min}" page="{$page}" page-size="{$page-size}" total="{$total}">
    {
      for $pret at $pos in $prets
      where $pos >= $start and $pos <= $end
      let $livre := db:get("isi_bibliotheque")/bibliotheque/livres/livre[@isbn=$pret/livreRef/text()]
      let $utilisateur := db:get("isi_bibliotheque")/bibliotheque/utilisateurs/utilisateur[@id=$pret/utilisateurRef/text()]
      return
        <pret id="{$pret/@id}">
          <livre isbn="{$pret/livreRef/text()}">
            <titre>{$livre/titre/text()}</titre>
            <auteur>{$livre/auteur/text()}</auteur>
          </livre>
          <utilisateur id="{$pret/utilisateurRef/text()}">
            <nom>{$utilisateur/nom/text()}</nom>
            <prenom>{$utilisateur/prenom/text()}</prenom>
            <email>{$utilisateur/email/text()}</email>
          </utilisateur>
          <datePret>{$pret/datePret/text()}</datePret>
          <dateRetourPrevue>{$pret/dateRetourPrevue/text()}</dateRetourPrevue>
          <joursRetard>{
            days-from-duration(current-date() - xs:date($pret/dateRetourPrevue/text()))
          }</joursRetard>
        </pret>
    }
  </resultats>
