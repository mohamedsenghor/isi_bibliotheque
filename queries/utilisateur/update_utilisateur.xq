xquery version "3.1";

declare namespace db = "http://basex.org/modules/db";
declare namespace update = "http://basex.org/modules/update";
declare namespace validate = "http://basex.org/modules/validate";

declare variable $id external;
declare variable $nom external;
declare variable $prenom external;
declare variable $email external;

let $utilisateur := db:get("isi_bibliotheque")/bibliotheque/utilisateurs/utilisateur[@id=$id]
let $existingEmail := db:get("isi_bibliotheque")/bibliotheque/utilisateurs/utilisateur[email=$email and @id != $id]

(: Construction de l'utilisateur modifié pour validation :)
let $utilisateurModifie := 
  <utilisateur id="{$id}">
    <nom>{$nom}</nom>
    <prenom>{$prenom}</prenom>
    <email>{$email}</email>
  </utilisateur>

(: Validation XSD de l'utilisateur modifié :)
let $validation := 
  try {
    validate:xsd($utilisateurModifie, "data/v2/bibliotheque.xsd")
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
  else if (not(exists($utilisateur))) then
    update:output(
      <resultat status="error">
        <message>Utilisateur avec ID {$id} non trouvé</message>
      </resultat>
    )
  else if (exists($existingEmail)) then
    update:output(
      <resultat status="error">
        <message>Un autre utilisateur utilise déjà email {$email}</message>
      </resultat>
    )
  else if (not(matches($email, "^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$"))) then
    update:output(
      <resultat status="error">
        <message>Format email invalide</message>
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
      replace value of node $utilisateur/nom with $nom,
      replace value of node $utilisateur/prenom with $prenom,
      replace value of node $utilisateur/email with $email,
      update:output(
        <resultat status="success">
          <message>Utilisateur mis à jour avec succès (validé par XSD)</message>
          <utilisateur id="{$id}">
            <nom>{$nom}</nom>
            <prenom>{$prenom}</prenom>
            <email>{$email}</email>
          </utilisateur>
        </resultat>
      )
    )
