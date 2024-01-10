const express = require('express');
const bodyParser = require('body-parser');
const routes = require('./routes/router.js');
const socketFunc = require('./routes/socket')
require('dotenv').config();

const app = express();

// Middleware
app.use(bodyParser.urlencoded({extended: true, limit: "50mb"}))
app.use(bodyParser.json())
require('./middleware/sql_connect.js')


var port = 3000;
var ip = process.env.IP;

var server = app.listen(port, ip, () => console.log(`running at host ${ip} on port ${port}`));


app.use(routes);
socketFunc(server);