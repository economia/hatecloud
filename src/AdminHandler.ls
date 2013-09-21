module.exports = class AdminHandler
    ({@sockets}:io, @shouts, @config) ->
        @sockets.on \connection (socket) ~>
            if socket.handshake.address.address not in @config.allowedIps
                return socket.disconnect('unauthorized');
            console.log "Admin connected"
            @sendCurrentContent socket

    sendCurrentContent: (socket) ->
        (err, content) <~ @shouts.getUnapproved
        socket.emit \shouts content
