xquery version "3.1";

import module namespace livre = "http://groupeisi.com/livre/est_emprunte" at "../livre/est_emprunte.xq";

declare namespace db = "http://basex.org/modules/db";
declare namespace update = "http://basex.org/modules/update";

declare variable $livre-isbn external;
declare variable $utilisateur-id external;
declare variable $duree-jours external := "30";

let $livre := db:get("isi_bibliotheque")/bibliotheque/livres/livre[@isbn = $livre-isbn]
let $utilisateur := db:get("isi_bibliotheque")/bibliotheque/utilisateurs/utilisateur[@id = $utilisateur-id]
let $statut-livre := livre:est-emprunte($livre-isbn)
let $date-emprunt := current-date()
let $date-retour := $date-emprunt + xs:dayTimeDuration(concat('P', $duree-jours, 'D'))
let $nouveau-pret-id := concat('P', count(db:get("isi_bibliotheque")/bibliotheque/prets/pret) + 1)

return
    if (not(db:exists("isi_bibliotheque"))) then
      update:output(
        <resultat status="error">
          <message>Base de données isi_bibliotheque introuvable</message>
        </resultat>
      )
    else if ($livre-isbn = "" or $utilisateur-id = "") then
      update:output(
        <resultat status="error">
          <message>ISBN du livre et ID utilisateur sont obligatoires</message>
        </resultat>
      )
    else if ($statut-livre/@status = "error") then
      update:output($statut-livre)
    else if (not(exists($utilisateur))) then
      update:output(
        <resultat status="error">
          <message>Utilisateur avec ID {$utilisateur-id} introuvable</message>
        </resultat>
      )
    else if ($statut-livre/@status = "indisponible") then
      update:output(
        <resultat status="error">
          <message>Le livre {$livre-isbn} n'est pas disponible pour l'emprunt</message>
          <details>{$statut-livre/details/*}</details>
        </resultat>
      )
    else
      (
        insert node
          <pret id="{$nouveau-pret-id}">
            <livreRef>{$livre-isbn}</livreRef>
            <utilisateurRef>{$utilisateur-id}</utilisateurRef>
            <datePret>{$date-emprunt}</datePret>
            <dateRetourPrevue>{$date-retour}</dateRetourPrevue>
            <dateRetourEffectif/>
            <statut>en cours</statut>
          </pret>
        into db:get("isi_bibliotheque")/bibliotheque/prets,
        
        replace value of node $livre/disponible with 'false',
        
        update:output(
          <resultat status="success">
            <message>Prêt enregistré avec succès</message>
            <pret id="{$nouveau-pret-id}">
              <livre>{$livre/titre/text()}</livre>
              <utilisateur>{concat($utilisateur/prenom/text(), ' ', $utilisateur/nom/text())}</utilisateur>
              <datePret>{$date-emprunt}</datePret>
              <dateRetourPrevue>{$date-retour}</dateRetourPrevue>
            </pret>
          </resultat>
        )
      )
