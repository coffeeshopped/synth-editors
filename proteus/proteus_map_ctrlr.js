
const ctrlr = {
  color: 1, 
  builders: (8).map(row =>
    ['panel', `row${row}`, { }, [
      (16).map(i => [`${row * 16 + i}`, row * 16 + i]),
    ]]
  ), 
  layout: [
    ['simpleGrid', (8).map(i => [`row${i}`, 1])],
  ],
}
