const abi = require('./contract.json')
const objectArray = Object.entries(abi);

objectArray.forEach(([key, value]) => {
  if(value.type == 'function' && value.inputs[0] != undefined) {
    console.log(value.name); // 1
console.log(Object.keys(value.inputs).length, value.inputs[0]); // 1
  }
});

var size = Object.keys(abi).length;
console.log(size)