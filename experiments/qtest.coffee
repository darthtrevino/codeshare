Q = require("q")

oneA = ->
  d = Q.defer()
  timeUntilResolve = Math.floor((Math.random() * 2000) + 1)
  console.log('1A Starting')
  setTimeout(( ->
    console.log('1A Finished')
    d.resolve('1ATime: ' + timeUntilResolve)
  ), timeUntilResolve)  
  d.promise

oneB = ->
    d = Q.defer()
    timeUntilResolve = Math.floor((Math.random() * 2000) + 1)
    console.log('1B Starting')
    setTimeout(( -> 
        console.log('1B Finished')
        d.resolve('1BTime: ' + timeUntilResolve)
    ), timeUntilResolve)
    d.promise

# This fuction throws an error which later on we show will be handled
two = (oneATime, oneBTime) ->
    d = Q.defer()
    console.log('OneA: ' + oneATime + ', OneB: ' + oneBTime)
    console.log('2 Starting and Finishing, so 3A and 3B should start')
    d.resolve()
    d.promise

threeA = ->
    d = Q.defer()
    console.log('3A Starting')
    setTimeout((->
        console.log('3A Finished')
        d.resolve()
    ), Math.floor((Math.random() * 2000) + 1))
    d.promise

threeB = ->
    d = Q.defer()
    console.log('3B Starting')
    setTimeout((->
        console.log('3B Finished')
        d.resolve()
    ), Math.floor((Math.random() * 5000) + 1))
    d.promise

Q.allSettled([ oneA(), oneB() ])
    .spread(two)
    .then(-> Q.all([threeA(), threeB()]))
    .then(-> console.log "Four is complete")
    .done()