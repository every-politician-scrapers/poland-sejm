const fs = require('fs');
let rawmeta = fs.readFileSync('meta.json');
let meta = JSON.parse(rawmeta);

// Use names from Polish Wikipedia
module.exports = function () {
  return `SELECT ?item ?name ?group ?klub_short
         (STRAFTER(STR(?statement), '/statement/') AS ?psid)
    WHERE
    {
      ?item p:P39 ?statement .
      ?statement ps:P39 wd:${meta.legislature.member} ; pq:P2937 wd:${meta.legislature.term.id} .
      FILTER NOT EXISTS { ?statement pq:P582 ?end }

      OPTIONAL {
        ?statement pq:P4100 ?group .
        OPTIONAL { ?group wdt:P1813  ?groupShort FILTER (LANG(?groupShort) = '${meta.source.lang.code}')}
        OPTIONAL { ?group rdfs:label ?groupName  FILTER (LANG(?groupName)  = '${meta.source.lang.code}')}
        BIND(COALESCE(?groupShort, ?groupName) as ?klub_short)
      }

      OPTIONAL { ?statement pq:P768 ?district }

      OPTIONAL {
        ?statement prov:wasDerivedFrom ?ref .
        ?ref (pr:P854|pr:P4656) ?source FILTER CONTAINS(STR(?source), 'pl.wikipedia.org')
        ?ref pr:P854 ?source FILTER CONTAINS(STR(?source), 'pl.wikipedia.org')
        OPTIONAL { ?ref pr:P1810 ?sourceName }
      }
      OPTIONAL { ?item rdfs:label ?wdLabel FILTER(LANG(?wdLabel) = "${meta.source.lang.code}") }
      BIND(COALESCE(?sourceName, ?wdLabel) AS ?name)

      SERVICE wikibase:label {
        bd:serviceParam wikibase:language "en,pl".
        ?genderItem rdfs:label ?gender .
        ?district rdfs:label ?districtLabel .
      }
    }
    # ${new Date().toISOString()}
    ORDER BY ?item`
}
