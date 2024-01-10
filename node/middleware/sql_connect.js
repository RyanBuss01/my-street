let mysql = require('mysql');
require('dotenv').config();

let connection = mysql.createConnection({
    host: 'localhost',
    user: 'root',
    password: 'password',
    database: 'local_schema'
});

connection.connect(function(err) { console.log('Connected to the MySQL database.'); });


  module.exports = connection;