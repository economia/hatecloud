module.exports = class AdminHandler
    ({@sockets}:io, @shouts, @config) ->
        @sockets.on \connection (socket) ~>
            if socket.handshake.address.address not in @config.allowedIps
                return socket.disconnect('unauthorized');
            console.log "Admin connected"
            @sendUnapproved socket
            @bindSocketEvents socket

    sendUnapproved: (socket) ->
        (err, content) <~ @shouts.getUnapproved
        socket.emit \unapproved content

    sendAll: (socket) ->
        (err, content) <~ @shouts.getAllByParty
        socket.emit \all content

    bindSocketEvents: (socket) ->
        socket.on \approveTerm (term) ~> @approveTerm socket, term
        socket.on \banTerm (term) ~> @banTerm socket, term
        socket.on \request (subject) ~> @fullfillRequest socket, subject

    approveTerm: (socket, term) ->
        <~ @shouts.approve term
        @sendUnapproved socket

    banTerm: (socket, term) ->
        <~ @shouts.ban term
        @sendUnapproved socket

    fullfillRequest: (socket, subject) ->
        switch subject
        | \unapproved => @sendUnapproved socket
        | \all => @sendAll socket
