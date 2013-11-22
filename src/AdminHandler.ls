require! async
module.exports = class AdminHandler
    ({@sockets}:io, @shouts, @config) ->
        @sockets.on \connection (socket) ~>
            if socket.handshake.address.address not in @config.allowedIps
                return socket.disconnect('unauthorized');
            console.log "Admin connected"
            @sendUnapproved socket
            @bindSocketEvents socket
        shouts.on \newUnapproved @~emitNewUnapproved

    sendUnapproved: (socket) ->
        (err, content) <~ @shouts.getUnapproved
        @sockets.emit \unapproved content

    sendAll: (socket) ->
        (err, content) <~ @shouts.getAllByParty
        <~ @decorateWithMood content
        socket.emit \all content

    decorateWithMood: (content, cb) ->
        <~ async.each content, (shout, cb) ~>
            (err, mood)<~ @shouts.getMood shout.term, shout.party
            shout.mood = mood
            cb!
        cb!


    bindSocketEvents: (socket) ->
        socket.on \approveTerm (data) ~> @approveTerm socket, data
        socket.on \banTerm (data) ~> @banTerm socket, data
        socket.on \setMood (data) ~> @setMood socket, data
        socket.on \request (subject) ~> @fullfillRequest socket, subject

    approveTerm: (socket, {term, party}) ->
        <~ @shouts.approve term, party
        @sendUnapproved socket

    banTerm: (socket, {term, party}) ->
        <~ @shouts.ban term, party
        @sendUnapproved socket

    setMood: (socket, {term, party, mood}) ->
        <~ @shouts.setMood term, party, mood
        @sendUnapproved socket

    fullfillRequest: (socket, subject) ->
        switch subject
        | \unapproved => @sendUnapproved socket
        | \all => @sendAll socket

    emitNewUnapproved: (term, partyId) ->
        @sockets.emit \newUnapproved {term, partyId}
