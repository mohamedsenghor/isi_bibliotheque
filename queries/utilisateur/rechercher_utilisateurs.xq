xquery version "3.1";

declare namespace db = "http://basex.org/modules/db";

declare variable $id external := "";
declare variable $prenom external := "";
declare variable $nom external := "";
declare variable $email external := "";

declare variable $page external := 1;
declare variable $page-size external := 10;

let $utilisateurs := 
  db:get("isi_bibliotheque")/bibliotheque/utilisateurs/utilisateur[
    ($id = "" or @id = $id) and
    ($prenom = "" or contains(lower-case(prenom), lower-case($prenom))) and
    ($nom = "" or contains(lower-case(nom), lower-case($nom))) and
    ($email = "" or contains(lower-case(email), lower-case($email)))
  ]

let $total := count($utilisateurs)
let $start := ($page - 1) * $page-size + 1
let $end := $page * $page-size

return
  <resultats>
    <filtres>
      <id>{$id}</id>
      <prenom>{$prenom}</prenom>
      <nom>{$nom}</nom>
      <email>{$email}</email>
    </filtres>
    <pagination page="{$page}" page-size="{$page-size}" total="{$total}"/>
    <utilisateurs>
      {
        for $utilisateur at $pos in $utilisateurs
        where $pos >= $start and $pos <= $end
        return $utilisateur
      }
    </utilisateurs>
  </resultats>
