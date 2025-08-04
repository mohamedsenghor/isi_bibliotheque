xquery version "3.1";

declare namespace db = "http://basex.org/modules/db";

declare variable $isbn external := "";
declare variable $titre external := "";
declare variable $auteur external := "";
declare variable $genre external := "";
declare variable $annee-min external := "";
declare variable $annee-max external := "";
declare variable $disponible external := "";
declare variable $prix-min external := "";
declare variable $prix-max external := "";

declare variable $page external := 1;
declare variable $page-size external := 10;

let $livres := 
  db:get("isi_bibliotheque")/bibliotheque/livres/livre[
    ($isbn = "" or @isbn = $isbn) and
    ($titre = "" or contains(lower-case(titre), lower-case($titre))) and
    ($auteur = "" or contains(lower-case(auteur), lower-case($auteur))) and
    ($genre = "" or contains(lower-case(genre), lower-case($genre))) and
    ($annee-min = "" or xs:integer(annee) >= xs:integer($annee-min)) and
    ($annee-max = "" or xs:integer(annee) <= xs:integer($annee-max)) and
    ($disponible = "" or disponible = $disponible) and
    ($prix-min = "" or xs:decimal(prix) >= xs:decimal($prix-min)) and
    ($prix-max = "" or xs:decimal(prix) <= xs:decimal($prix-max))
  ]

let $total := count($livres)
let $start := ($page - 1) * $page-size + 1
let $end := $page * $page-size

return
  <resultats>
    <filtres>
      <isbn>{$isbn}</isbn>
      <titre>{$titre}</titre>
      <auteur>{$auteur}</auteur>
      <genre>{$genre}</genre>
      <annee-min>{$annee-min}</annee-min>
      <annee-max>{$annee-max}</annee-max>
      <disponible>{$disponible}</disponible>
      <prix-min>{$prix-min}</prix-min>
      <prix-max>{$prix-max}</prix-max>
    </filtres>
    <pagination page="{$page}" page-size="{$page-size}" total="{$total}"/>
    <livres>
      {
        for $livre at $pos in $livres
        where $pos >= $start and $pos <= $end
        return $livre
      }
    </livres>
  </resultats>
