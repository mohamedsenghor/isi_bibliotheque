xquery version "3.1";

declare namespace db = "http://basex.org/modules/db";

declare variable $utilisateur-id external := "";
declare variable $livre-isbn external := "";
declare variable $date-debut external := "";
declare variable $date-fin external := "";
declare variable $page external := 1;
declare variable $page-size external := 10;

let $prets := 
  db:get("isi_bibliotheque")/bibliotheque/prets/pret[
    ($utilisateur-id = "" or utilisateurRef = $utilisateur-id) and
    ($livre-isbn = "" or livreRef = $livre-isbn) and
    ($date-debut = "" or xs:date(datePret) >= xs:date($date-debut)) and
    ($date-fin = "" or xs:date(datePret) <= xs:date($date-fin))
  ]

let $total := count($prets)
let $start := ($page - 1) * $page-size + 1
let $end := $page * $page-size

return
  if (empty($prets)) then
    <resultats status="warning">
      <message>
        {
          if ($utilisateur-id != "") then
            concat("Aucun historique trouvé pour utilisateur ", $utilisateur-id)
          else
            "Aucun prêt trouvé"
        }
      </message>
    </resultats>
  else
    <resultats utilisateur="{$utilisateur-id}" page="{$page}" page-size="{$page-size}" total="{$total}">
      {
        for $pret at $pos in $prets
        where $pos >= $start and $pos <= $end
        let $livre := db:get("isi_bibliotheque")/bibliotheque/livres/livre[@isbn = $pret/livreRef]
        let $en-cours := empty($pret/dateRetour) or normalize-space($pret/dateRetour) = ""
        return
          <pret en-cours="{if ($en-cours) then 'oui' else 'non'}">
            <livre>
              <isbn>{$livre/@isbn}</isbn>
              <titre>{$livre/titre/string()}</titre>
              <auteur>{$livre/auteur/string()}</auteur>
            </livre>
            <datePret>{$pret/datePret/string()}</datePret>
            <dateRetour>{$pret/dateRetour/string()}</dateRetour>
          </pret>
      }
    </resultats>
