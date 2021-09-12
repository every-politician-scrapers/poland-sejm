const fs = require('fs');
let rawmeta = fs.readFileSync('meta.json');
let meta = JSON.parse(rawmeta);

module.exports = (id) => {
  qualifier = {
    P2937: meta.legislature.term.id,
  }

  source = {
    P143: 'Q1551807',
    P4656: 'https://pl.wikipedia.org/w/index.php?title=Pos%C5%82owie_na_Sejm_Rzeczypospolitej_Polskiej_IX_kadencji&oldid=64497291',
    P813: new Date().toISOString().split('T')[0],
  }

  return {
    id,
    claims: {
      P39: {
        value: meta.legislature.member,
        qualifiers: qualifier,
        references: source,
      }
    }
  }
}
