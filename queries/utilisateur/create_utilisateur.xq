xquery version "3.1";

declare namespace db = "http://basex.org/modules/db";
declare namespace update = "http://basex.org/modules/update";
declare namespace validate = "http://basex.org/modules/validate";

declare variable $id external := "";
declare variable $nom external := "";
declare variable $prenom external := "";
declare variable $email external := "";

let $existingUtilisateur := db:get("isi_bibliotheque")/bibliotheque/utilisateurs/utilisateur[@id=$id]
let $existingEmail := db:get("isi_bibliotheque")/bibliotheque/utilisateurs/utilisateur[email=$email]
let $nouvelUtilisateur := 
  <utilisateur id="{$id}">
    <nom>{$nom}</nom>
    <prenom>{$prenom}</prenom>
    <email>{$email}</email>
  </utilisateur>

(: Validation XSD du nouvel utilisateur :)
let $validation := 
  try {
    validate:xsd($nouvelUtilisateur, "data/v2/bibliotheque.xsd")
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
  else if ($id = "" or $nom = "" or $prenom = "" or $email = "") then
    update:output(
      <resultat status="error">
        <message>Tous les champs (ID, nom, prénom, email) sont obligatoires</message>
      </resultat>
    )
  else if (exists($existingUtilisateur)) then
    update:output(
      <resultat status="error">
        <message>Un utilisateur avec ID {$id} existe déjà</message>
      </resultat>
    )
  else if (exists($existingEmail)) then
    update:output(
      <resultat status="error">
        <message>Un utilisateur avec email {$email} existe déjà</message>
      </resultat>
    )
  else if (not(matches($email, "^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$"))) then
    update:output(
      <resultat status="error">
        <message>Format d'email invalide</message>
      </resultat>
    )
  else if (string-length($id) < 2 or string-length($id) > 10) then
    update:output(
      <resultat status="error">
        <message>L'ID doit contenir entre 2 et 10 caractères</message>
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
      insert node $nouvelUtilisateur into db:get("isi_bibliotheque")/bibliotheque/utilisateurs,
      update:output(
        <resultat status="success">
          <message>Utilisateur créé avec succès</message>
          <utilisateur id="{$id}">
            <nom>{$nom}</nom>
            <prenom>{$prenom}</prenom>
            <email>{$email}</email>
          </utilisateur>
        </resultat>
      )
    )
