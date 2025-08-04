xquery version "3.1";

module namespace livre = "http://groupeisi.com/livre/est_emprunte";
declare namespace db = "http://basex.org/modules/db";

declare function livre:est-emprunte($isbn as xs:string) as element(resultat) {
    let $livre := db:get("isi_bibliotheque")/bibliotheque/livres/livre[@isbn = $isbn]
    let $prets-actifs := db:get("isi_bibliotheque")/bibliotheque/prets/pret[
        livreRef = $isbn and 
        (
            (statut = "en cours") or
            (statut = "retourné" and xs:date(dateRetourEffectif) > current-date() - xs:dayTimeDuration("P3D"))
        )
    ]
    return
        if (not(exists($livre))) then
            <resultat status="error">
                <message>Livre avec ISBN {$isbn} introuvable</message>
            </resultat>
        else if (exists($prets-actifs)) then
            <resultat status="indisponible">
                <message>Le livre est actuellement emprunté</message>
                <details>
                    <livre>
                        <isbn>{$isbn}</isbn>
                        <titre>{$livre/titre/text()}</titre>
                    </livre>
                    <pret>
                        <id>{$prets-actifs[1]/@id/string()}</id>
                        <statut>{$prets-actifs[1]/statut/text()}</statut>
                        <datePret>{$prets-actifs[1]/datePret/text()}</datePret>
                        <dateRetourPrevue>{$prets-actifs[1]/dateRetourPrevue/text()}</dateRetourPrevue>
                        {
                            if ($prets-actifs[1]/dateRetourEffectif) then
                                <dateRetourEffectif>{$prets-actifs[1]/dateRetourEffectif/text()}</dateRetourEffectif>
                            else ()
                        }
                        <jours-depuis-emprunt>{
                            days-from-duration(current-date() - xs:date($prets-actifs[1]/datePret/text()))
                        }</jours-depuis-emprunt>
                        {
                            if ($prets-actifs[1]/statut = "en cours") then
                                <jours-retard>{
                                    max((0, days-from-duration(current-date() - xs:date($prets-actifs[1]/dateRetourPrevue/text()))))
                                }</jours-retard>
                            else ()
                        }
                    </pret>
                </details>
            </resultat>
        else
            <resultat status="disponible">
                <message>Le livre est disponible</message>
                <livre>
                    <isbn>{$isbn}</isbn>
                    <titre>{$livre/titre/text()}</titre>
                    <auteur>{$livre/auteur/text()}</auteur>
                    <genre>{$livre/genre/text()}</genre>
                </livre>
                <dernier-pret>{
                    let $dernier-pret := db:get("isi_bibliotheque")/bibliotheque/prets/pret[livreRef = $isbn]
                    order by xs:date($dernier-pret/datePret) descending
                    return $dernier-pret[1]
                }</dernier-pret>
            </resultat>
};
