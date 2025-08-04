xquery version "3.1";

declare namespace db = "http://basex.org/modules/db";
declare namespace update = "http://basex.org/modules/update";

declare variable $id external;

let $utilisateur := db:get("isi_bibliotheque")/bibliotheque/utilisateurs/utilisateur[@id=$id]
let $pretsActifs := db:get("isi_bibliotheque")/bibliotheque/prets/pret[utilisateurRef=$id and statut="en cours"]

return
  if (not(db:exists("isi_bibliotheque"))) then
    update:output(
      <resultat status="error">
        <message>Base de données isi_bibliotheque introuvable</message>
      </resultat>
    )
  else if ($id = "") then
    update:output(
      <resultat status="error">
        <message>L'ID utilisateur est obligatoire</message>
      </resultat>
    )
  else if (not(exists($utilisateur))) then
    update:output(
      <resultat status="error">
        <message>Utilisateur avec ID {$id} introuvable</message>
      </resultat>
    )
  else if (exists($pretsActifs)) then
    update:output(
      <resultat status="error">
        <message>Impossible de supprimer utilisateur {$id} car il a des prêts en cours</message>
        <details>
          <prets-actifs count="{count($pretsActifs)}">
            {
              for $pret in $pretsActifs
              return 
                <pret id="{$pret/@id}">
                  <livre>{$pret/livreRef/text()}</livre>
                  <datePret>{$pret/datePret/text()}</datePret>
                </pret>
            }
          </prets-actifs>
        </details>
      </resultat>
    )
  else
    (
      delete node $utilisateur,
      update:output(
        <resultat status="success">
          <message>Utilisateur supprimé avec succès</message>
          <utilisateur-supprime id="{$id}">
            <nom>{$utilisateur/nom/text()}</nom>
            <prenom>{$utilisateur/prenom/text()}</prenom>
            <email>{$utilisateur/email/text()}</email>
          </utilisateur-supprime>
        </resultat>
      )
    )
