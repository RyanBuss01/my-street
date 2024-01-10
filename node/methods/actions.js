const sqlDB = require('../middleware/sql_connect')
const defaultAvatar = require('../constants/default_avatar')
const bcrypt = require('bcrypt');

var functions = {

    uploadMedia : function(req, res) {
        try {
            res.status(200).send(req.file.location);
          }catch(err) {
            if(err) {console.log(err)}
            res.status(400).send();
          }
    },

    signup : async function(req, res) {
        var json = {
            email : req.body.email,
            password : req.body.password,
            firstName : req.body.firstName,
            lastName : req.body.lastName,
            username : req.body.username,
            displayName : req.body.displayName,
            birthday : req.body.birthday
        }

        let emailCheckSql = 
        `
        SELECT * FROM my_street.User
        WHERE User.email = '${json.email}'
        `

        let usernameSql = `
        SELECT * FROM my_street.User
        WHERE User.username = '${json.username}'
        `

        const salt = await bcrypt.genSalt(10);
        var password = await bcrypt.hash(json.password, salt);

        var sql =  `INSERT 
        INTO my_street.User (email, firstName, lastName, displayName, username, avatar, password, birthday) 
        SELECT '${json.email}', '${json.firstName}', '${json.lastName}', '${json.displayName}', '${json.username}', '${defaultAvatar}', '${password}', '${json.birthday}'
        WHERE NOT EXISTS (
            SELECT * FROM my_street.User
            WHERE User.email = '${json.email}'
            )
        `;

        let storySql =  (userId) => `
            INSERT INTO my_street.Story (owner_id, type)
            VALUES (${userId}, 'main')
            `

        sqlDB.query(emailCheckSql, function(err, result0) {
            if(err) {res.status(400).send(), console.log(err)}
            if(result0.length > 0) {res.status(203).send({error : 'email'})}
            else {
            sqlDB.query(usernameSql, function(err, result0) {
                if(err) {res.status(400).send(), console.log(err)}
                if(result0.length > 0) {res.status(203).send({error : 'username'})}
                else {

        sqlDB.query(sql, function(err, result) {
            if(err)  {res.status(400).send(), console.log(err)}
            sqlDB.query(storySql(result.insertId), function(err, result2) {
                if(err) {res.status(400).send(), console.log(err)}
                res.status(200).send({id : result.insertId})
            })
        
      })
    }
    })
}
    })
    },

    signin : async function (req, res) {
        let sql = `SELECT * FROM my_street.User WHERE email = '${req.body.email}'`;

        sqlDB.query(sql, async function (err, result) {

            if(err) {res.status(400), console.log(err)}
            if(result.length == 0) {res.status(204).send()}
            else {
                var userdata = result[0];

                const validPassword = await bcrypt.compare(req.body.password, userdata.password);
                if(validPassword) {res.status(200).send({user_id : userdata.id})}
                else {res.status(400).send({msg: 'invalid password'})}
            }
        })

        
    },

    getUserData : async function (req, res) {  
        var json = {
            id : Number(req.headers.id),
            myId : Number(req.headers.myid),
            username : req.headers.username
        }

        if(req.headers.querytype == 'byId') {
        let sql; 
        if(req.headers.isme == 'true') {
            sql = `
            SELECT User.id as user_id, User.username, User.displayName, User.bio, User.avatar
            FROM my_street.User 
            LEFT JOIN my_street.FriendRequest 
            ON FriendRequest.receiver = ${json.id}
            AND User.id = ${json.id}
            GROUP BY User.id
            LIMIT 1
            `;
        }
        else {
            sql = `
            SELECT User.id as user_id, User.displayName, User.bio, User.avatar, FriendRequest.receiver, FriendRequest.sender, Friends.status as friend_status, UserLocation.latitude, UserLocation.longitude, UserLocation.dt
            FROM my_street.User 
            LEFT JOIN my_street.UserLocation
            ON User.id = UserLocation.user_id
            LEFT JOIN my_street.Friends 
            ON Friends.user1_id = ${json.id} AND Friends.user2_id = ${json.myId} OR Friends.user1_id = ${json.myId} AND Friends.user2_id = ${json.id}
            LEFT JOIN my_street.FriendRequest 
            ON FriendRequest.sender = ${json.id} AND FriendRequest.receiver = ${json.myId} OR FriendRequest.receiver = ${json.id} AND FriendRequest.sender = ${json.myId}
            WHERE User.id = ${json.id}
        `
        }

        sqlDB.query(sql, function (err, result) {
            if(err) {res.status(200).send(), console.log(err)}
            var userdata = result[0];
            res.status(200).send(userdata)
        })
    }
    if(req.headers.querytype == 'byUsername') {
        let sql = `
        SELECT User.id as user_id, User.displayName, User.bio, User.avatar, FriendRequest.receiver, FriendRequest.sender, Friends.status, UserLocation.dt
        FROM my_street.User 
        LEFT JOIN my_street.Friends 
        ON Friends.user1_id = User.id AND Friends.user2_id = ${json.myId} OR Friends.user1Id = ${json.myId} AND Friends.user2Id = User.id
        LEFT JOIN my_street.FriendRequest 
        ON FriendRequest.sender = User.id AND FriendRequest.receiver = ${json.myId} OR FriendRequest.receiver = User.id AND FriendRequest.sender = ${json.myId}
        WHERE displayName = '${json.username}'
        `

        sqlDB.query(sql, function (err, result) {
            if(err) {res.status(200).send(), console.log(err)}
            var userdata = result[0];
            res.status(200).send(userdata)
        })
    }
    },

    updateUserData : function (req, res) {
        var comma = '';
        var sql = `UPDATE my_street.User SET `;
        if(req.body.displayName != '') {
             sql += `displayName = '${req.body.displayName}' `;
             comma = ',';
        }
        if(req.body.bio != '') { 
            sql += `${comma} bio = '${req.body.bio}'`;
            comma = ','
        }
        if(req.body.avatar != '') { 
            sql += `${comma} avatar = '${req.body.avatar}' `;
            comma = ','
    }
        sql += ` WHERE User.id = ${Number(req.body.id)}`;


        sqlDB.query(sql, function(err, result) {
            if(err) {res.status(400).send(), console.log(err)}

            let userSql = `
            SELECT User.id as user_id, User.username, User.displayName, User.bio, User.avatar, Story.id as story_id, Story.dt
            FROM my_street.User 
            LEFT JOIN my_street.FriendRequest 
            ON FriendRequest.receiver = ${Number(req.body.id)}
            LEFT JOIN my_street.Story
            ON Story.owner_id = ${Number(req.body.id)}
            AND Story.type = 'mainUserStory'
            WHERE User.id = ${Number(req.body.id)} 
            `
            sqlDB.query(userSql, function(err, result2) {
                if(err) {res.status(400).send(), console.log(err)}
                var userdata = result2[0];
                res.status(200).send(userdata)
            })
        })
    },

    updateUserLocation : function (req, res) {
        var json = {
            userId : req.body.userId,
            latitude : req.body.latitude,
            longitude : req.body.longitude
        }

        sql = `
        INSERT INTO my_street.UserLocation (user_id, latitude, longitude)
        VALUES (${json.userId}, ${json.latitude}, ${json.longitude})
        ON DUPLICATE KEY UPDATE
        latitude = ${json.latitude},
        longitude = ${json.longitude}
        `

        sqlDB.query(sql, function(err, result) {
            if(err) {res.status(400).send(), console.log(err)}
            res.status(200).send()
        })

    },

    mapQuery : function (req, res) {
        var json = {
            myLatitude : parseFloat(req.headers.userlatitude),
            myLongitude : parseFloat(req.headers.userlongitude),
            myId : Number(req.headers.userid),
            diff : functions.zoomDiffScaler(req.headers.zoom),
            boundN : functions.boundScaler('north', parseFloat(req.headers.zoom), parseFloat(req.headers.boundn)),
            boundS : functions.boundScaler('south', parseFloat(req.headers.zoom), parseFloat(req.headers.bounds)),
            boundE : functions.boundScaler('east', parseFloat(req.headers.zoom), parseFloat(req.headers.bounde)),
            boundW : functions.boundScaler('west', parseFloat(req.headers.zoom), parseFloat(req.headers.boundw)),
            zoom : parseFloat(req.headers.zoom)
        }

        let sqlPost = `
        SELECT caption, Post.id as post_id, User.id as user_id, Post.dt, Post.type as post_type, media, latitude, longitude, displayName, avatar
            FROM my_street.Post
            JOIN my_street.User 
            ON my_street.Post.user_id = my_street.User.id
            LEFT JOIN my_street.Friends 
            ON Friends.user1_id = User.id AND Friends.user2_id = ${json.myId} OR Friends.user1_id = ${json.myId} AND Friends.user2_id = User.id
            LEFT JOIN my_street.BlockedUser
            ON Post.user_id = BlockedUser.blocked_by AND BlockedUser.blocked_to = ${json.myId} OR BlockedUser.blocked_to = Post.user_id AND BlockedUser.blocked_by = ${json.myId}
            WHERE longitude <= ${json.boundE} AND longitude >= ${json.boundW} AND latitude <= ${json.boundN} AND latitude >= ${json.boundS} 
            AND BlockedUser.blocked_to IS NULL
            GROUP BY Post.id
            ORDER BY Friends.status = 'friend' DESC
            , Post.ts DESC
         `;

         let sqlUser = `
         SELECT user_id as user_id, latitude, longitude, username, displayName, avatar
             FROM my_street.UserLocation
             JOIN my_street.User 
             ON UserLocation.user_id = User.id
             INNER JOIN my_street.Friends 
             ON Friends.user1_id = User.id AND Friends.user2_id = ${json.myId} OR Friends.user1_id = ${json.myId} AND Friends.user2_id = User.id
             WHERE longitude <= ${json.boundE} AND longitude >= ${json.boundW} AND latitude <= ${json.boundN} AND latitude >= ${json.boundS}
          `;

          let sqlPlace = `
          SELECT id as place_id, name, latitude, longitude, media
             FROM my_street.Place
             WHERE ${json.zoom} > 14
             AND longitude <= ${json.boundE} AND longitude >= ${json.boundW} AND latitude <= ${json.boundN} AND latitude >= ${json.boundS}
          `

          sqlDB.query(sqlUser, function (err, userResult) {
            if(err) {res.status(400).send; console.log(err)}

        
        sqlDB.query(sqlPost, function (err, postResult) {
            if(err) {res.status(400).send; console.log(err)}

            sqlDB.query(sqlPlace, function (err, placeResult) {
                if(err) {res.status(400).send; console.log(err)}

            var uI = 0, pI = 0, plI = 0;
            var usersList = userResult;
            var postList = postResult;
            var placeList = placeResult;
            var userStack = [], postsStack = [], placeStack = [], completedPost = [], completedUser = [], completedPlace = [], myStackUserList = [], myStackPostList = [];
            var myStack;

            

            
            myStackUserList = usersList.filter(e => (
                e.latitude <= json.myLatitude + json.diff
                && e.latitude >= json.myLatitude - json.diff
                && e.longitude <= json.myLongitude + json.diff
                && e.longitude >= json.myLongitude - json.diff));

            myStackPostList = postList.filter(e => (
                e.latitude <= json.myLatitude + json.diff
                && e.latitude >= json.myLatitude - json.diff
                && e.longitude <= json.myLongitude + json.diff
                && e.longitude >= json.myLongitude - json.diff));

                for (var index in myStackUserList) {
                    completedUser.push(myStackUserList[index].user_id)
                }

                for (index in myStackPostList) {
                    completedPost.push(myStackPostList[index].post_id)
                }

                myStack = {userCount: myStackUserList.length, postCount: myStackPostList.length}

                completedUser.push(json.myId);

                for (var int in placeResult) {
                    if(completedPlace.includes(placeList[int].place_id) == false) {
                    var placeUserStackList = usersList.filter(e => (
                        e.latitude <= json.myLatitude + json.diff
                        && e.latitude >= json.myLatitude - json.diff
                        && e.longitude <= json.myLongitude + json.diff
                        && e.longitude >= json.myLongitude - json.diff));
                    

                    var placePostStackList = postList.filter(e => (
                        e.latitude <= json.myLatitude + json.diff
                        && e.latitude >= json.myLatitude - json.diff
                        && e.longitude <= json.myLongitude + json.diff
                        && e.longitude >= json.myLongitude - json.diff));

                        placeStack[plI] = {place: placeList[int], userCount: placeUserStackList.length, postCount: placePostStackList.length}
                        plI++;
                        for(var index in list) {
                            completedUser.push(placeUserStackList[index].user_id)
                        }
                        for (index in postLoopList) {
                            completedPost.push(placePostStackList[index].post_id)
                        }
                        completedPlace.push(placeList[int].place_id)
                    }

                }


            for (var int in userResult) {
                if(completedUser.includes(userResult[int].user_id) == false) {
                    var list = []
                    var postLoopList = []
                    list = usersList.filter(e => (
                    e.latitude <= userResult[int].latitude + json.diff
                    && e.latitude >= userResult[int].latitude - json.diff
                    && e.longitude <= userResult[int].longitude + json.diff
                    && e.longitude >= userResult[int].longitude - json.diff));

                    postLoopList = postList.filter(e => (
                        e.latitude <= userResult[int].latitude + json.diff
                        && e.latitude >= userResult[int].latitude - json.diff
                        && e.longitude <= userResult[int].longitude + json.diff
                        && e.longitude >= userResult[int].longitude - json.diff));
                
                    
        
                    userStack[uI] = {displayUser: list[0], userCount: list.length, postCount: postLoopList.length}
                    uI++;
                    for(var index in list) {
                        completedUser.push(list[index].user_id)
                    }
                    for (index in postLoopList) {
                        completedPost.push(postLoopList[index].post_id)
                    }
                }
                }

                for (var int in postResult) {

                    if(completedPost.includes(postResult[int].post_id) == false) {
                        var list = []
                        list = postList.filter(e => (
                        e.latitude <= postResult[int].latitude + json.diff
                        && e.latitude >= postResult[int].latitude - json.diff
                        && e.longitude <= postResult[int].longitude + json.diff
                        && e.longitude >= postResult[int].longitude - json.diff));
                        
                        var displayPost = list.find(e => (e.contentType === 'image'));
            
                        if(displayPost == null) { displayPost = list[0] }
            
                        postsStack[pI] = {post: displayPost, count: list.length}
                        pI++;
                        for(var index in list) {
                            completedPost.push(list[index].post_id)
                        }
                        
                    }
                    }

                    res.status(200).send({myStack: myStack, users: userStack, posts: postsStack, places: placeStack})

        });
    })
    })
          
    },

    addFriend : function (req, res) {
        if(req.body.status == 'none') {
            var sql = `
                INSERT my_street.FriendRequest (sender, receiver, status)
                SELECT ${Number(req.body.myId)}, ${Number(req.body.altId)}, 'pending'
                WHERE NOT EXISTS (
                    SELECT * FROM my_street.FriendRequest 
                    WHERE sender = ${Number(req.body.myId)} 
                    AND receiver = ${Number(req.body.altId)}
                    OR sender = ${Number(req.body.altId)} 
                    AND receiver = ${Number(req.body.myId)}
                    LIMIT 1
                )
            `
            sqlDB.query(sql, function(err, result) {
                if(err) {res.status(400).send(); console.log(err)}
                res.status(200).send() 
            })
        }
            if(req.body.status == 'receiver') {
                var sql = 
                `
                DELETE FROM my_street.FriendRequest
                WHERE sender = ${Number(req.body.myId)}
                AND receiver =  ${Number(req.body.altId)}
                OR sender = ${Number(req.body.altId)}
                AND receiver = ${Number(req.body.myId)}
                `

                var sql2 = `
                
                INSERT my_street.Friends (user1_id, user2_id, status)
                SELECT ${Number(req.body.myId)}, ${Number(req.body.altId)}, 'friend'
                WHERE NOT EXISTS (
                    SELECT * FROM my_street.Friends 
                    WHERE user1_id = ${Number(req.body.myId)} 
                    AND user2_id = ${Number(req.body.altId)}
                    OR user1_id = ${Number(req.body.altId)} 
                    AND user2_id = ${Number(req.body.myId)}
                    LIMIT 1
                );
                `
                sqlDB.query(sql, function(err, result) { if(err) {res.status(400).send(); console.log(err)} })
                sqlDB.query(sql2, function(err, result) {
                    if(err) {res.status(400).send(); console.log(err)}
                    res.status(200).send() 
                })
            }
            if(req.body.status == 'sender') {
                var deleteSql = 
               `
               DELETE FROM my_street.FriendRequest
               WHERE sender = ${Number(req.body.myId)}
               AND receiver =  ${Number(req.body.altId)}
               OR sender = ${Number(req.body.altId)}
               AND receiver = ${Number(req.body.myId)}
               `

               sqlDB.query(deleteSql, function(err, result) {
                if(err) {res.status(400).send(); console.log(err)}
                res.status(200).send() 
            })
            }
    },

    reportPost: function (req, res) {
        var json = {
            postId : req.body.postId,
            userId : req.body.userId
        }
        var sql = `
                INSERT my_street.ReportPost (post_id, user_id)
                VALUES ${json.postId}, ${json.userId})
            `
            sqlDB.query(sql, function(err, result) {
                if(err) {res.status(400).send(); console.log(err)}
                res.status(200).send() 
            })
    },

    getFriendsList : function(req, res) {
        var offset;
        if(req.headers.chunkset == 0) {
            offset = 0
        } else {
        offset = (Number(req.headers.chunkset) - 1) * 10
        }

        var sqlOffset;
        if(offset == 0) sqlOffset = '';
        else sqlOffset = ` ${offset}, `

        let sql = `
        SELECT * FROM my_street.User
        WHERE EXISTS (
            SELECT * FROM my_street.Friends
            WHERE user1_id = ${req.headers.myid}
            AND user2_id = User.id
            OR user2_id = ${req.headers.myid}
            AND user1_id = User.id
        )
        LIMIT ${sqlOffset} 10
        `

        sqlDB.query(sql, function(err, result) {
            if(err) {res.status(400).send(); console.log(err)}
            res.status(200).send(result)
        })
    },
    
    removeFriend: function(req, res) {
        let sql =
        `
        DELETE FROM my_street.Friends
        WHERE user1_id = ${Number(req.headers.myid)} 
        AND user2_id = ${Number(req.headers.id)}
        OR user1_id = ${Number(req.headers.id)} 
        AND user2_id = ${Number(req.headers.myid)}
        LIMIT 1
        `

        sqlDB.query(sql, function(err, result) {
            if(err) {res.status(400).send(); console.log(err)}
            res.status(200).send() 
        })
    },

    getFriendRequestList : function (req, res) {
        var offset = (Number(req.headers.chunkset) - 1) * 10

        var sqlOffset;
        if(offset == 0) sqlOffset = '';
        else sqlOffset = ` ${offset}, `
        
        let sql = `
        SELECT * FROM my_street.User
        WHERE EXISTS (
            SELECT * FROM my_street.FriendRequest
            WHERE receiver = ${req.headers.myid}
            AND sender = User.id
        )
        LIMIT ${sqlOffset} 10
        `

        sqlDB.query(sql, function(err, result) {
            if(err) {res.status(400).send(); console.log(err)}
            res.status(200).send(result)
        })
    },

    blockUser: function(req, res) {
        var sql = `
        INSERT my_street.BlockedUser (blocked_by, blocked_to)
        SELECT ${Number(req.body.myId)}, ${Number(req.body.altId)}
        WHERE NOT EXISTS (
            SELECT * FROM my_street.BlockedUser 
            WHERE blocked_by = ${Number(req.body.myId)} 
            AND blocked_to = ${Number(req.body.altId)}
            LIMIT 1
        )
    `
    sqlDB.query(sql, function(err, result) {
        if(err) {res.status(400).send(); console.log(err)}
        res.status(200).send() 
    })
    },

    unblockUser : function (req, res) {
        let sql =
        `
        DELETE FROM my_street.BlockedUser
        WHERE blocked_by = ${Number(req.headers.myid)} 
        AND blocked_to = ${Number(req.headers.altid)}
        `

        sqlDB.query(sql, function(err, result) {
            if(err) {res.status(400).send(); console.log(err)}
            res.status(200).send() 
        })
    },

    getBlockedUsers : function(req, res) {
        var offset = (Number(req.headers.chunkset) - 1) * 10

        var sqlOffset;
        if(offset == 0) sqlOffset = '';
        else sqlOffset = ` ${offset}, `

        let sql = `
        SELECT * FROM my_street.BlockedUser
        INNER JOIN my_street.User
        ON User.id = BlockedUser.blocked_to
        WHERE BlockedUser.blocked_by = ${req.headers.id}
        LIMIT ${sqlOffset} 10
        `

        sqlDB.query(sql, function(err, result) {
            if(err) {res.status(400).send(); console.log(err)}
            res.status(200).send(result)
        })
    },

    search : function(req, res) {
        var searchString = req.headers.search;

        let userSql = `
        SELECT User.id as user_id, User.avatar, User.username, User.displayName, Friends.status as friend_status
         FROM my_street.User 
        LEFT JOIN my_street.Friends 
        ON Friends.user1_id = User.id AND Friends.user2_id = ${Number(req.headers.userid)} OR Friends.user1_id = ${Number(req.headers.userid)} AND Friends.user2_id = User.id
        LEFT JOIN my_street.BlockedUser
        ON User.id = BlockedUser.blocked_by
        WHERE displayName 
        LIKE '${searchString}%'
        AND BlockedUser.blocked_to  IS NULL
        ORDER BY Friends.status = 'friend' DESC
        LIMIT 5
        `

        let tagSql = `
        SELECT tag, id as tag_id, count(*) AS postCount
        FROM my_street.hashTag
        WHERE tag 
        LIKE '${searchString}%'
        GROUP BY tag
        LIMIT 5
        `

        sqlDB.query(userSql, function(err, users) {
            if(err) {res.status(400).send(); console.log(err)}
            sqlDB.query(tagSql, function(err, tags) {
                if(err) {res.status(400).send(); console.log(err)}
                res.status(200).send({users, tags})
            })
        })
    },

    userSearch :function(req, res) {
        var searchString = req.headers.search;

        var offset = (Number(req.headers.chunkset) - 1) * 10

        var sqlOffset;
        if(offset == 0) sqlOffset = '';
        else sqlOffset = `${offset}, `

        var sqlLimit= '';
        if(req.headers.iscaption == 'true') sqlLimit = `LIMIT ${sqlOffset} 10`;

        var getFriendsSql = ''
        if(req.headers.getfriends == 'true') getFriendsSql = `AND Friends.status IS NOT NULL`;

        let sql = `
        SELECT User.id as user_id, User.avatar, User.displayName, User.username, Friends.status as friend_status
        FROM my_street.User 
        LEFT JOIN my_street.Friends 
        ON Friends.user1_id = User.id AND Friends.user2_id = ${Number(req.headers.userid)} OR Friends.user1_id = ${Number(req.headers.userid)} AND Friends.user2_id = User.id
        LEFT JOIN my_street.BlockedUser
        ON User.id = BlockedUser.blocked_by AND BlockedUser.blocked_to = ${Number(req.headers.userid)} OR BlockedUser.blocked_to = User.id AND BlockedUser.blocked_by = ${Number(req.headers.userid)}
        WHERE displayName 
        LIKE '${searchString}%'
        AND BlockedUser.blocked_to IS NULL
        ${getFriendsSql}
        ORDER BY Friends.status = 'friend' DESC
        ${sqlLimit}
        `

        sqlDB.query(sql, function(err, users) {
            if(err) {res.status(400).send(); console.log(err)}
                res.status(200).send({users})
        })
    },

    uploadPost : function (req, res) {
        var json = {
            userId : Number(req.body.userId),
            latitude : parseFloat(req.body.latitude),
            longitude : parseFloat(req.body.longitude),
            media : req.body.media,
            type : req.body.type,
        }

        let sql = `INSERT 
      INTO my_street.Post (user_id, latitude, longitude, media, type) 
      VALUES (${json.userId}, ${json.latitude}, ${json.longitude}, '${json.media}', '${json.type}')`;

      
        sqlDB.query(sql, function (err, result) {
            if(err) {res.status(400).send(), console.log(err)}
            res.status(200).send()
            
    })
    },

    getUserPosts : function (req, res) {
        let sql = `
        SELECT Post.id as post_id, Post.dt, Post.type as post_type, Post.media, latitude, longitude, Post.user_id, Reply.id as reply_id, Reply.msg, Reply.media as liveReplyMedia, Reply.replyTo_id, Post.caption
            FROM my_street.Post
            LEFT JOIN my_street.Reply
            ON Reply.user_id = ${req.headers.myid}
            AND Reply.post_id = Post.id
            WHERE Post.user_id = ${req.headers.id}
            GROUP BY Post.id
         `;


        sqlDB.query(sql, function (err, result) {
            if(err) {res.status(400).send; console.log(err)}
            res.status(200).send(result)
        })
    },

    uploadLiveReply : function (req, res) {
        var json = {
            replyId : Number(req.body.replyId),
            userId : Number(req.body.userId),
            postId : Number(req.body.postId),
            replyId : req.body.replyId != 'null' ? Number(req.body.replyId) : null,
            msg : req.body.msg == 'null' ? null : `'${req.body.msg}'`,
            media : req.body.media == 'null' ? null : `'${req.body.media}'`,
        }

        let sql = `INSERT 
            INTO my_street.reply (user_id, post_id, media, msg) 
            VALUES (${json.userId}, ${json.postId}, ${json.media}, ${json.msg})`;

        var getSql = (id) => {
            return `
            SELECT id as reply_id, user_id, post_id, msg, media as liveReplyMedia, replyTo_id, dt as reply_dt
            FROM my_street.Reply
            WHERE user_id = ${json.userId}
            AND id = ${id}
            LIMIT 1
            `}
        

        var setSql;
        if(json.msg != null) {
            setSql = `msg = ${json.msg}`;
        }
        if(json.media != null) {
            setSql = `media = ${json.media}`;
        }

        let upldateSql = `
        UPDATE  my_street.reply
            SET ${setSql}
            WHERE user_id = ${json.userId}
            AND id = ${json.replyId}
            LIMIT 1
            `;
            

        

        if(json.replyId == null) {

      
        sqlDB.query(sql, function (err, result) {
            if(err) {res.status(400).send(), console.log(err)}

            sqlDB.query(getSql(result.insertId), function (err, result2) {
                if(err) {res.status(400).send(), console.log(err)}
    
                
                res.status(200).send(result2)
                
            })            
        })
        } else {

            sqlDB.query(upldateSql, function (err, result) {
                if(err) {res.status(400).send(), console.log(err)}
    
                sqlDB.query(getSql(json.replyId), function (err, result2) {
                    if(err) {res.status(400).send(), console.log(err)}
        
                    
                    res.status(200).send(result2)
                    
                })            
            })
        }
    },

    uploadPostCaption: function (req, res) {
        var json = {
            caption : req.body.caption,
            userId : Number(req.body.userId),
            postId : Number(req.body.postId),
        }

        let sql = `
        UPDATE my_street.Post
            SET caption = '${json.caption}'
            WHERE id = ${json.postId}
            `;

        

        sqlDB.query(sql, function (err, result) {
            if(err) {res.status(400).send(), console.log(err)}
            res.status(200).send()          
        })
    },

    getOverlayPosts : function (req, res) {
        var json = {
            userId: Number(req.headers.userid),
            diff: functions.zoomDiffScaler(req.headers.zoom),
            latDiff: Number(req.headers.latitude),
            longDiff: Number(req.headers.longitude)
        }

        let sql = `
        SELECT caption, Post.id as post_id, User.id as user_id, Post.dt, Post.media, Post.type as post_type, latitude, longitude, displayName, username, avatar, Reply.id as reply_id, Reply.msg, Reply.media as liveReplyMedia, Reply.replyTo_id
            FROM my_street.Post
            JOIN my_street.User 
            ON my_street.Post.user_id = my_street.User.id
            LEFT JOIN my_street.Reply
            ON Reply.user_id = ${json.userId}
            AND Reply.post_id = Post.id
            LEFT JOIN my_street.Friends 
            ON Friends.user1_id = User.id AND Friends.user2_id = ${json.userId} OR Friends.user1_id = ${json.userId} AND Friends.user2_id = User.id
           WHERE longitude <= ${(json.longDiff + json.diff)} AND longitude >= ${(json.longDiff - json.diff)} 
            AND latitude <= ${(json.latDiff + json.diff)} AND latitude >= ${(json.latDiff - json.diff)}
            GROUP BY Post.id
            
            
         `; // Order by latest

        sqlDB.query(sql, function (err, result) {
            if(err) {res.status(400).send; console.log(err)}
            res.status(200).send(result)
        })
    },

    zoomDiffScaler(zoomString) {
        var zoom = Number(zoomString)
        var diff;

        if(zoom > 17){ diff = 0.0002; }
        else if(zoom <= 17 && zoom > 16) { diff = 0.0005; }
        else if (zoom <= 16 && zoom > 15) { diff = 0.0015;}
        else if(zoom <= 15 && zoom > 14) { diff = 0.003;  }
        else if(zoom <= 14 && zoom > 13) { diff = 0.007; }
        else if(zoom <= 13 && zoom > 12) { diff = 0.01; }
        else if(zoom <= 12 && zoom > 11) { diff = 0.02; }
        else if(zoom <= 11 && zoom > 10) { diff = 0.04; }
        else if(zoom <= 10 && zoom > 9) { diff = 0.075; }
        else if(zoom <= 9 && zoom > 8) { diff = 0.15; }
        else if(zoom <= 8 && zoom > 7) { diff = 0.4;  }
        else if(zoom <= 7 && zoom > 6) { diff = 0.8; }
        else if(zoom <= 6 && zoom > 5) { diff = 1.5; }
        else if(zoom <= 5 && zoom > 4) { diff = 3; }
        else if(zoom <= 4) { diff = 7; }
        else {diff = 0;}

        return diff;
    },

    boundScaler(boundKey, zoom, bound) {
        var diff;
    
        if(zoom > 17){ diff = 0.0007; }
        else if(zoom <= 17 && zoom > 16) { diff = 0.001; }
        else if (zoom <= 16 && zoom > 15) { diff = 0.0026;}
        else if(zoom <= 15 && zoom > 14) { diff = 0.006;  }
        else if(zoom <= 14 && zoom > 13) { diff = 0.01; }
        else if(zoom <= 13 && zoom > 12) { diff = 0.02; }
        else if(zoom <= 12 && zoom > 11) { diff = 0.05; }
        else if(zoom <= 11 && zoom > 10) { diff = 0.1; }
        else if(zoom <= 10 && zoom > 9) { diff = 0.14; }
        else if(zoom <= 9 && zoom > 8) { diff = 0.3; }
        else if(zoom <= 8 && zoom > 7) { diff = 1;  }
        else if(zoom <= 7 && zoom > 6) { diff = 3; }
        else if(zoom <= 6 && zoom > 5) { diff = 5; }
        else if(zoom <= 5 && zoom > 4) { diff = 7; }
        else if(zoom <= 4) { diff = 10; }
        else {diff = 0;}
    
        if(boundKey == 'west' || boundKey == 'south') {
          diff = (diff * -1);
        }
    
        newBound = bound + diff;

    
    
        return newBound;
      }
}

module.exports = functions;