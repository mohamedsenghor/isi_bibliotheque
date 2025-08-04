xquery version "3.1";

import module namespace db = "http://basex.org/modules/db";

let $databaseName := "isi_biblio"
let $xmlFile := "/data/v2/bibliotheque.xml"

return 
  if (db:exists($databaseName)) then
      "Database already exists"
  else
      (
          db:create($databaseName, $xmlFile),
          "Database created and data inserted successfully"
      )
