xquery version "3.1";

declare namespace db = "http://basex.org/modules/db";
declare namespace update = "http://basex.org/modules/update";
declare namespace validate = "http://basex.org/modules/validate";

declare variable $isbn external := "";
declare variable $titre external := "";
declare variable $auteur external := "";
declare variable $genre external := "";
declare variable $annee external := "";
declare variable $disponible external := "true";
declare variable $prix external := "0";

let $existingLivre := db:get("isi_bibliotheque")/bibliotheque/livres/livre[@isbn=$isbn]
let $nouveauLivre := 
  <livre isbn="{$isbn}">
    <titre>{$titre}</titre>
    <auteur>{$auteur}</auteur>
    <genre>{$genre}</genre>
    <annee>{$annee}</annee>
    <disponible>{$disponible}</disponible>
    <prix>{$prix}</prix>
  </livre>

(: Validation XSD du nouveau livre :)
let $validation := 
  try {
    validate:xsd($nouveauLivre, "data/v2/bibliotheque.xsd")
  } catch * {
    <validation-error>
      <code>{$err:code}</code>
      <description>{$err:description}</description>
    </validation-error>
  }

return 
  if (not(db:exists("isi_bibliotheque"))) then
    update:output(
      <resultat status="error">
        <message>Base de données isi_bibliotheque introuvable</message>
      </resultat>
    )
  else if ($isbn = "" or $titre = "" or $auteur = "") then
    update:output(
      <resultat status="error">
        <message>Les champs ISBN, titre et auteur sont obligatoires</message>
      </resultat>
    )
  else if (exists($existingLivre)) then
    update:output(
      <resultat status="error">
        <message>Un livre avec l'ISBN {$isbn} existe déjà</message>
      </resultat>
    )
  else if ($annee != "" and (xs:integer($annee) < 1000 or xs:integer($annee) > year-from-date(current-date()))) then
    update:output(
      <resultat status="error">
        <message>L'année doit être comprise entre 1000 et {year-from-date(current-date())}</message>
      </resultat>
    )
  else if ($prix != "" and xs:decimal($prix) < 0) then
    update:output(
      <resultat status="error">
        <message>Le prix ne peut pas être négatif</message>
      </resultat>
    )
  else if (exists($validation/validation-error)) then
    update:output(
      <resultat status="error">
        <message>Erreur de validation XSD</message>
        <details>
          <code>{$validation/validation-error/code/text()}</code>
          <description>{$validation/validation-error/description/text()}</description>
        </details>
      </resultat>
    )
  else
    (
      insert node $nouveauLivre into db:get("isi_bibliotheque")/bibliotheque/livres,
      update:output(
        <resultat status="success">
          <message>Livre créé avec succès</message>
          <livre isbn="{$isbn}">
            <titre>{$titre}</titre>
            <auteur>{$auteur}</auteur>
            <genre>{$genre}</genre>
            <annee>{$annee}</annee>
            <disponible>{$disponible}</disponible>
            <prix>{$prix}</prix>
          </livre>
        </resultat>
      )
    )
