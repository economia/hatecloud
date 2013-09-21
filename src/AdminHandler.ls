module.exports = class AdminHandler
    ({@sockets}:io, @shouts, @config) ->
        @sockets.on \connection (socket) ~>
            if socket.handshake.address.address not in @config.allowedIps
                return socket.disconnect('unauthorized');
            console.log "Admin connected"
            @sendCurrentContent socket
            @bindSocketEvents socket

    sendCurrentContent: (socket) ->
        (err, content) <~ @shouts.getUnapproved
        socket.emit \shouts content

    bindSocketEvents: (socket) ->
        socket.on \approveTerm (term) ~> @approveTerm socket, term
        socket.on \banTerm (term) ~> @banTerm socket, term

    approveTerm: (socket, term) ->
        <~ @shouts.approve term
        @sendCurrentContent socket

    banTerm: (socket, term) ->
        <~ @shouts.ban term
        @sendCurrentContent socket
