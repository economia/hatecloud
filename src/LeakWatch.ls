require! \memwatch
module.exports = watch = ->
    new LeakWatch!

class LeakWatch
    hd: null
    statsInterval: 30
    currentStatsCounter: 0
    ->
        memwatch.on \leak (info) ->
            console.error "Possible memory leak detected"
            console.error info
        memwatch.on \stats (stats) ~>
            ++@currentStatsCounter
            console.log @currentStatsCounter
            if @currentStatsCounter >= @statsInterval
                @currentStatsCounter = 0
                console.log "Memory stats"
                data = @hd.end!
                console.log JSON.stringify data, null "  "
                @hd = null
            if not @hd
                @hd = new memwatch.HeapDiff!
