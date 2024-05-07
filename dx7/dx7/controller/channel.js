const { ctrlr } = require('/core/Controller.js')
  
function controller(vc) {    
  vc.grid([[
    [{l: "Channel"}, "channel"],
  ]])

  vc.color()
}


module.exports = () => ctrlr(controller)
