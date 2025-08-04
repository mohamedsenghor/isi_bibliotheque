xquery version "3.1";

import module namespace livre = "http://groupeisi.com/livre/est_emprunte" at "../livre/est_emprunte.xq";

declare namespace db = "http://basex.org/modules/db";
declare namespace update = "http://basex.org/modules/update";

declare variable $pret-id external;

let $pret := db:get("isi_bibliotheque")/bibliotheque/prets/pret[@id=$pret-id]
let $livre-isbn := $pret/livreRef/text()
let $livre := db:get("isi_bibliotheque")/bibliotheque/livres/livre[@isbn=$livre-isbn]
let $statut-livre := livre:est-emprunte($livre-isbn)

return
  if (not(db:exists("isi_bibliotheque"))) then
    update:output(
      <resultat status="error">
        <message>Base de données isi_bibliotheque introuvable</message>
      </resultat>
    )
  else if ($pret-id = "") then
    update:output(
      <resultat status="error">
        <message>L'ID du prêt est obligatoire</message>
      </resultat>
    )
  else if (not(exists($pret))) then
    update:output(
      <resultat status="error">
        <message>Prêt avec ID {$pret-id} introuvable</message>
      </resultat>
    )
  else if ($pret/statut = 'retourné') then
    update:output(
      <resultat status="error">
        <message>Le livre {$livre-isbn} a déjà été retourné</message>
      </resultat>
    )
  else if ($statut-livre/@status = "error") then
    update:output($statut-livre)
  else if ($statut-livre/@status = "disponible") then
    update:output(
      <resultat status="error">
        <message>Le livre {$livre-isbn} n'est pas actuellement emprunté selon l'historique</message>
      </resultat>
    )
  else (
    replace value of node $pret/statut with 'retourné',
    replace value of node $pret/dateRetourEffectif with current-date(),
    replace value of node $livre/disponible with 'true',
    update:output(
      <resultat status="success">
        <message>Retour enregistré avec succès</message>
        <pret id="{$pret-id}">
          <livre>{$livre/titre/text()}</livre>
          <dateRetourEffectif>{current-date()}</dateRetourEffectif>
          <utilisateur>{
            let $utilisateur := db:get("isi_bibliotheque")/bibliotheque/utilisateurs/utilisateur[@id=$pret/utilisateurRef/text()]
            return concat($utilisateur/prenom/text(), ' ', $utilisateur/nom/text())
          }</utilisateur>
        </pret>
      </resultat>
    )
  )
