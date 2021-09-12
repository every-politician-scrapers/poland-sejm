const fs = require('fs');
let rawmeta = fs.readFileSync('meta.json');
let meta = JSON.parse(rawmeta);

module.exports = (id, term) => {
  qualifier = {
    P2937: term,
  }

  return {
    id,
    claims: {
      P39: {
        value: meta.legislature.member,
        qualifiers: qualifier,
      }
    }
  }
}
