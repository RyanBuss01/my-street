const socketFunction = require('../methods/socketMethods');


function SocketFunction(server) {
    
    let socket = require('socket.io')(server)

    socket.on("connection", (userSocket) => {
        userSocket.on('getChatRooms', (data) => socketFunction.getChatRooms(data, userSocket));
        userSocket.on('GetChatRoomMessages', (data) => socketFunction.GetChatRoomMessages(data, userSocket));
        userSocket.on('getSingleChatroom', (data) => socketFunction.getSingleChatroom(data, userSocket));
        userSocket.on('emitMessage', (data) => {socketFunction.emitMessage(data, userSocket)})    
        })

}

module.exports = SocketFunction;