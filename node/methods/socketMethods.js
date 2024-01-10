const res = require('express/lib/response')
const sqlDB = require('../middleware/sql_connect')

var socketFunctions = {

    getChatRooms : function(data, socket) {
        var friendSql = '';

        if(data.friendsOnly == true) {
            friendSql = 
            `AND Friends.status IS NOT NULL`
        }
    
        let sql = `
        SELECT Chatroom.id as chatroom_id, Chatroom.type as chatroom_type, ChatroomMessage.id as message_id, ChatroomMessage.content, ChatroomMessage.type as message_type, ChatroomMessage.dt as msgDt, ChatroomMessageRead.dt as readDt, ChatroomMessageRead.id as read_id, User.id as user_id, User.displayName, User.username, User.avatar, Friends.status as friend_status
        FROM my_street.Chatroom
        LEFT JOIN my_street.ChatRoomParticipant p1
        ON p1.chatroom_id = Chatroom.id
        AND p1.user_id = ${data.userId}
        LEFT JOIN my_street.ChatRoomParticipant p2
        ON Chatroom.type = 'direct'
        AND p2.chatroom_id = Chatroom.id
        AND p2.user_id != ${data.userId}
        INNER JOIN my_street.ChatroomMessage
        ON Chatroom.id = ChatroomMessage.chatroom_id
        AND ChatroomMessage.id =
        (
            SELECT id as message_id
            FROM my_street.ChatroomMessage m1
            WHERE m1.chatroom_id = Chatroom.id
            ORDER  BY ts DESC
            LIMIT 1
        )
        LEFT JOIN my_street.User
        ON User.id = p2.user_id
        AND User.id != ${data.userId}
        AND Chatroom.type = 'direct'
        OR Chatroom.type = 'group'
        AND User.id = Chatroom.owner_id
        LEFT JOIN my_street.ChatroomMessageRead
        ON ChatroomMessageRead.chatroom_id = Chatroom.id
        AND ChatroomMessageRead.user_id = ${data.userId}
        LEFT JOIN my_street.Friends
        ON p1.user_id = Friends.user1_id
        AND p2.user_id = Friends.user2_id
        AND Chatroom.type = 'direct'            
        OR p2.user_id = Friends.user1_id
        AND p1.user_id = Friends.user2_id
        AND Chatroom.type = 'direct'
        LEFT JOIN my_street.BlockedUser
        ON BlockedUser.blocked_to = p2.user_id 
        AND BlockedUser.blocked_by = p1.user_id
        WHERE p1.user_id = ${data.userId}
        AND Chatroom.type = 'group'
        OR p1.user_id = ${data.userId}
        AND Chatroom.type = 'direct'
        AND BlockedUser.blocked_to IS NULL
        ${friendSql}
        GROUP BY Chatroom.id
        `

        sqlDB.query(sql, function(err, result) {
            if(err) {console.log(err)}
            socket.emit('getChatRooms', result)
        })

    },

    GetChatRoomMessages: function(data, socket){
        if(data.chatroomId != null) {}
        let sql= `
        SELECT ChatroomMessage.id as message_id, ChatroomMessage.chatroom_id, ChatroomMessage.content, ChatroomMessage.type as message_type, User.id as user_id, User.displayName, User.username, User.avatar,  msgUser.id as msg_user_id, msgUser.displayName as msg_displayName, msgUser.username as msg_username, msgUser.avatar as msg_avatar, post.id as post_id, post.type as post_type, post.media as post_media, post.caption as post_caption
        FROM my_street.ChatroomMessage
        LEFT JOIN my_street.User
        ON User.id = ChatroomMessage.user_id
        LEFT JOIN my_street.GeoPost post
        ON post.id = ChatroomMessage.content
        AND ChatroomMessage.type = 'geoPost' 
        LEFT JOIN  my_street.User msgUser
        ON post.user_id = msgUser.id
        AND ChatroomMessage.type = 'geoPost' 
        OR ChatroomMessage.type = 'user' 
        AND msgUser.id = ChatroomMessage.content
        WHERE ChatroomMessage.chatroom_id = ${data.chatroomId}
        GROUP BY ChatroomMessage.id
        ORDER BY ChatroomMessage.ts DESC
        `

        sqlDB.query(sql, function(err, result) {
            if(err) {console.log(err)}
            socket.emit('GetChatRoomMessages', result)
        })
        
    },

    getSingleChatroom : function(data, socket) {
        if(data.isGroup == true) {
                        
                let sql = `
                SELECT ChatroomMessage.id as message_id, ChatroomMessage.chatroom_id, ChatroomMessage.user_id, ChatroomMessage.content, ChatroomMessage.type as message_type, User.id, User.displayName, User.username, User.avatar 
                FROM my_street.ChatroomMessage
                LEFT JOIN my_street.User
                ON User.id = ChatroomMessage.user_id
                WHERE ChatroomMessage.chatroom_id = (
                    SELECT ChatRoom.id FROM my_street.ChatRoom
                    LEFT JOIN my_street.ChatroomParticipant
                    ON ChatRoomParticipant.chatroom_id = Chatroom.id
                    LEFT JOIN my_street.User
                    ON User.id = ChatroomParticipant.user_id
                    WHERE ChatRoomParticipant.user_id IN (${data.userIds})
                    AND ChatRoom.type = 'group'
                    HAVING COUNT(DISTINCT ChatroomParticipant.id) = ${data.userIds.length}
                )
                `
    
                sqlDB.query(sql, function(err, result) {
                    if(err) {console.log(err)}
                    socket.emit('getSingleChatroom', result ?? [])
                })
        }

        else {

        
            let sql = `
            SELECT ChatroomMessage.id as message_id, ChatroomMessage.chatroom_id, ChatroomMessage.user_id, ChatroomMessage.content, ChatroomMessage.type as message_type, User.id, User.displayName, User.username, User.avatar 
            FROM my_street.ChatroomMessage
            LEFT JOIN my_street.User
            ON User.id = ChatroomMessage.user_id
            WHERE ChatroomMessage.chatroom_id = (
                SELECT ChatRoom.id 
                FROM my_street.ChatRoom
                LEFT JOIN my_street.ChatroomParticipant AS p1
                ON p1.chatroom_id = Chatroom.id
                AND  p1.user_id = ${data.userIds[0]}
                LEFT JOIN my_street.ChatroomParticipant AS p2
                ON p2.chatroom_id = Chatroom.id
                AND  p2.user_id = ${data.userIds[1]}
                LEFT JOIN my_street.User
                ON User.id = p1.user_id
                WHERE p1.chatroom_id = p2.chatroom_id
                AND ChatRoom.type = 'direct'
            )
            `

            sqlDB.query(sql, function(err, result) {
                if(err) {console.log(err)}
                socket.emit('getSingleChatroom', result ?? [])
            })
    }
    },

    emitMessage : function(data, socket) {
            let json = {
                roomExists : data.roomExists,
                roomType : data.roomType,
                roomId : data.roomId,
                userIds : data.userIds,
                userId : data.userId,
                allIds : data.userIds,
                content : data.content,
                contentType : data.contentType,
                ownerId : (data.roomType == 'group') ? data.userId : null,
            }


            var sqlJson = {
                getRoomSql : `SELECT Chatroom.id
                                FROM my_street.Chatroom
                                LEFT JOIN my_street.ChatRoomParticipant p1
                                ON Chatroom.id = p1.chatroom_id
                                AND p1.user_id = ${json.userId}
                                LEFT JOIN my_street.ChatRoomParticipant p2
                                ON Chatroom.id = p1.chatroom_id
                                AND p2.user_id = ${json.userIds[0]}
                                WHERE Chatroom.type = 'direct'
                                LIMIT 1
                                `,
                getMessages : (roomId) => {
                    return `
                    SELECT ChatroomMessage.id as message_id, ChatroomMessage.chatroom_id, ChatroomMessage.content, ChatroomMessage.type as message_type, User.id as user_id, User.displayName, User.username, User.avatar, msgUser.id as msg_user_id, msgUser.displayName as msg_displayName, msgUser.avatar as msg_avatar, msgUser.username as msg_username, post.id as post_id, post.type as post_id, post.media as post_media, post.caption as post_media
                    FROM my_street.ChatroomMessage
                    LEFT JOIN my_street.User
                    ON User.id = ChatroomMessage.user_id
                    LEFT JOIN my_street.GeoPost post
                    ON post.id = ChatroomMessage.content
                    AND ChatroomMessage.type = 'geoPost' 
                    LEFT JOIN  my_street.User msgUser
                    ON post.user_id = msgUser.id
                    AND ChatroomMessage.type = 'geoPost' 
                    OR ChatroomMessage.type = 'user' 
                    AND msgUser.id = ChatroomMessage.content
                    WHERE ChatroomMessage.chatroom_id = ${roomId}
                    GROUP BY ChatroomMessage.id
                    ORDER BY ChatroomMessage.ts DESC
                    `;
                    },
                getMessageSql : (roomId) => {
                    return `
                    INSERT INTO my_street.ChatroomMessage (chatroom_id, user_id, content, type)
                    VALUES (${roomId}, ${json.userId}, '${json.content}', '${json.contentType}')
                    `
                },

                participantSql : (userId, roomId) => {
                    return `
                    INSERT INTO my_street.ChatRoomParticipant (user_id, chatroom_id)
                    VALUES (${userId}}, ${roomId})
                    `
                },

                chatroomSql : `
                INSERT INTO my_street.Chatroom (type, owner_id)
                VALUES ('${json.roomType}', ${json.ownerId}) 
                `
            }




            if(json.roomExists || json.roomId != null) {
                sqlDB.query(sqlJson.getMessageSql(json.roomId), function(err, result2) {
                    if(err) {console.log(err)}

                        sqlDB.query(sqlJson.getMessages(json.roomId), function(err, result3) {
                            if(err) {console.log(err)}

                            socket.emit('GetChatRoomMessages', result3)
                        })
                })
        }



        else if(json.contentType == 'geoPost' || json.contentType == 'user') {

                    sqlDB.query(sqlJson.getRoomSql, function(err, result) { if(err) {console.log(err)}
                        console.log(result)
                        if(result == null) {

                            sqlDB.query(sqlJson.chatroomSql, function(err, result) {
                                if(err) {res.status(400); console.log(err)}
                                
                                var users = [json.userIds[0], json.userId];

                                for ( let i in users) {
                                    sqlDB.query(sqlJson.participantSql(users[i], result.insertId), function(err, result2) {if(err) {console.log(err)}})
                                }

                                sqlDB.query(sqlJson.getMessageSql(result.insertId), function(err, result2) {
                                    if(err) {console.log(err)}

                                        sqlDB.query(sqlJson.getMessages(result.insertId), function(err, result3) {
                                            if(err) {console.log(err)}
                                        })
                                })
                            })
                        }

                        else  {
                            sqlDB.query(sqlJson.getMessageSql(result[0].chatroom_id), function(err, result2) {
                            if(err) {console.log(err)}
                            })
                        }
                    })
            }

        else {
            if(!json.roomExists) {

                sqlDB.query(sqlJson.chatroomSql, function(err, result) {
                    if(err) {res.status(400); console.log(err)}

                    for ( let i in json.userIds) {
                        sqlDB.query(sqlJson.participantSql(json.userIds[i], result.insertId), function(err, result2) {if(err) {console.log(err)}})
                    }

                    sqlDB.query(sqlJson.getMessageSql(result.insertId), function(err, result2) {
                        if(err) {console.log(err)}

                            sqlDB.query(sqlJson.getMessages(result.insertId), function(err, result3) {
                                if(err) {console.log(err)}
                                socket.emit('GetChatRoomMessages', result3)
                            })
                    })
                })

            } 
        }
    },

}

module.exports = socketFunctions;