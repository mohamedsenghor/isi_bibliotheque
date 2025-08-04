xquery version "3.1";

import module namespace livre = "http://groupeisi.com/livre/est_emprunte" at "est_emprunte.xq";

declare namespace db = "http://basex.org/modules/db";
declare namespace update = "http://basex.org/modules/update";

declare variable $isbn external;

let $livre := db:get("isi_bibliotheque")/bibliotheque/livres/livre[@isbn=$isbn]
let $statut-emprunt := livre:est-emprunte($isbn)

return
  if (not(db:exists("isi_bibliotheque"))) then
    update:output(
      <resultat status="error">
        <message>Base de données isi_bibliotheque introuvable</message>
      </resultat>
    )
  else if ($isbn = "") then
    update:output(
      <resultat status="error">
        <message>L'ISBN est obligatoire</message>
      </resultat>
    )
  else if (not(exists($livre))) then
    update:output(
      <resultat status="error">
        <message>Livre avec ISBN {$isbn} introuvable</message>
      </resultat>
    )
  else if ($statut-emprunt/@status = "error") then
    update:output($statut-emprunt)
  else if ($statut-emprunt/@status = "indisponible") then
    update:output(
      <resultat status="error">
        <message>Impossible de supprimer le livre {$isbn} car il est actuellement emprunté ou récemment retourné</message>
        <details>{$statut-emprunt/details/*}</details>
      </resultat>
    )
  else
    (
      delete node $livre,
      update:output(
        <resultat status="success">
          <message>Livre supprimé avec succès</message>
          <livre-supprime isbn="{$isbn}">
            <titre>{$livre/titre/text()}</titre>
            <auteur>{$livre/auteur/text()}</auteur>
          </livre-supprime>
        </resultat>
      )
    )
