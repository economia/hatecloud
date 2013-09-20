window.VoteWatcher = class VoteWatcher
    voted: null
    ->
        if Cookies.get \votes
            @voted = JSON.parse that
        if !@voted?length then @voted = []

    didVote: (id) ->
        id in @voted

    registerVote: (id) ->
        @voted.push id
        Cookies.set do
            \votes
            JSON.stringify @voted
            7
            '/'

