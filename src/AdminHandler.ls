module.exports = class AdminHandler
    ({@sockets}:io, @config) ->
        @sockets.on \connection (socket) ~>
