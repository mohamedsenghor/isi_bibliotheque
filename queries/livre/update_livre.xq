xquery version "3.1";

declare namespace db = "http://basex.org/modules/db";

declare variable $isbn external;
declare variable $titre external;
declare variable $auteur external;
declare variable $genre external;
declare variable $annee external;
declare variable $disponible external;
declare variable $prix external;

let $livre := db:get("isi_bibliotheque")/bibliotheque/livres/livre[@isbn=$isbn]

return
  if (exists($livre)) then
    (
      replace value of node $livre/titre with $titre,
      replace value of node $livre/auteur with $auteur,
      replace value of node $livre/genre with $genre,
      replace value of node $livre/annee with $annee,
      replace value of node $livre/disponible with $disponible,
      replace value of node $livre/prix with $prix,
      <resultat operation="update" status="success">
        <message>Livre mis à jour avec succès</message>
        <livre>{$livre}</livre>
      </resultat>
    )
  else
    <resultat operation="update" status="error">
      <message>Livre avec ISBN {$isbn} non trouvé</message>
    </resultat>
