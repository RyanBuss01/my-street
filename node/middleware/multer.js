const aws = require('aws-sdk');
const multer = require('multer');
const multerS3 = require('multer-s3');
require('dotenv').config();


aws.config.update({
    secretAccessKey: process.env.AWS_ACCESS_KEY_SECRET,
    accessKeyId: process.env.AWS_ACCESS_KEY_ID,
    region: 'us-east-1'
});

var s3 = new aws.S3();

var upload = multer({
    storage: multerS3({
        s3: s3,
        bucket: process.env.AWS_BUCKET_NAME,
        key: function (req, file, cb) {
            cb(null, `image/${Date.now().toString()}-${file.originalname}`); //use Date.now() for unique file keys
        }
    })
});

module.exports = upload;