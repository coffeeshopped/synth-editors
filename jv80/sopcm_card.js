
const piano = {
  id: 1,
  name: "Piano Selections", 
  waves: [],
  patches: [],
}
const guitarBrass = {
  id: 2,
  name: "Guitar and Brass", 
  waves: [],
  patches: [],
}
const drums = {
  id: 3,
  name: "Rock Drums", 
  waves: [],
  patches: [],
}
const grand = {
  id: 4,
  name: "Grand Piano",
  waves: [],
  patches: [],
}
const accordion = {
  id: 5,
  name: "Accordion",
  waves: [],
  patches: [],
}
const baroque = {
  id: 6,
  name: "Baroque",
  waves: [],
  patches: [],
}
const orch = {
  id: 7,
  name: "Orchestral FX",
  waves: [],
  patches: [],
}
const country = {
  id: 8,
  name: "Country/Folk/Bluegrass",
  waves: [],
  patches: [],
}

const cards = [
  piano,
  guitarBrass,
  drums,
  grand,
  accordion,
  baroque,
  orch,
  country,
]

// indices are the model 
const cardsById = (() => {
  const cs = []
  cards.forEach(c => cs[c.id] = c)
  return cs
})()

const cardNames = (() => {
  const cs = []
  cards.forEach(c => cs[c.id] = c.name)
  return cs
})()

module.exports = {
  cards: cardsById,
  cardNames: cardNames,
}
