xquery version "3.1";

import module namespace livre = "http://groupeisi.com/livre/est_emprunte" at "../est_emprunte.xq";

let $statut-livre := livre:est-emprunte("L004")
return <resultat>{$statut-livre}</resultat>
