//Website server using Express

//TODO
    //Add 'username not found' and 'incorrect password' alerts
    //Ensure valid form inputs are kept when submitting unsuccessfully
    //Add session cabability to maintain/track logins

//Grab packages
const express = require('express');
const mysql = require('mysql');
const bodyParser = require('body-parser');
const security = require('./Security/SecurityTools.js'); //Import our security tools for hashing

//Set up express app
var app = express();
app.use(express.static(__dirname + '/')); //Use relative path names
app.use(bodyParser.urlencoded({ extended: true })); //Body parser - lets us grab data from the form
app.use(bodyParser.json());

//Set up database connection
var connection = mysql.createConnection({
    host: 'localhost',
    user: 'root',
    password: '',
    database: 'deliciousmeal'
});

// ------ Display Web pages ------ //

//Home Page
app.get('/home', (req, res) => {
    res.sendFile(__dirname + '/' + 'Home/HomePage.html');
});

//Login Page
app.get('/login', (req, res) => {
    res.sendFile(__dirname + '/' + 'Login/LoginPage.html');
});

//Registration Page
app.get('/register', (req, res) => {
    res.sendFile(__dirname + '/' + 'AccountCreation/AccountCreation.html');
});
// ------------------------------- //

// ------ Methods for login, account creation, etc. ------ //

//Process user login
app.post('/loginRequest', (req, res) => {

    //Store the submitted info
    var username = req.body.username;
    var password = req.body.password;

    //Database query - sees if the given username exists and grabs their salt/hashed password data if they do
    var query = `SELECT salt, hashedPassword FROM users WHERE username = '${username}'`;

    //Query the database if both fields submitted
    if (username && password) {
        connection.query(query, (error, results, fields) => {
            //If username found
            if (results.length > 0) {
                //Put query results into a usable form
                var userSalt = results[0].salt;
                var userPW = results[0].hashedPassword;

                //Hash the given password with the user's salt
                var hash = security.SHA256(password + userSalt);

                //Compare computed hash to user's stored password hash
                if (hash == userPW) {
                    //If they match, login and redirect to home page
                    res.redirect('/home');
                    console.log(`- User '${username}' logged in successfully`);
                }
                else {
                    //If not, go back to the login page to try again
                    res.redirect('/login');
                    console.log(`- User '${username}' failed to login`);
                }

            }
            //If username not found, go back to the login page
            else {
                console.log(`- Login attempt failed for username '${username}'`);
                res.redirect('/login');
                //Alert user that username not found
                //____________________
            }
        });
    }
});

//Process account creation request
app.post('/createAccount', (req, res) => {

    //Store the submitted info
    var username = req.body.username;
    var password = req.body.password;
    var confirmPassword = req.body.confirmPassword;
    var email = req.body.email;
    var firstName = req.body.firstName;
    var lastName = req.body.lastName;

    //If all required info is submitted
    if (username && password && confirmPassword && email) {

        //Check that the username does not already exist
        var checkQuery = `SELECT userID FROM users WHERE username = '${username}'`;
        connection.query(checkQuery, (error, results, fields) => {
            if (results.length > 0) { //True if an entry already contains the username
                res.redirect('/register');
            }
            //If username is new and unique
            else {
                if (password == confirmPassword) {
                    //Hash and salt the user's password
                    var salt = security.generateSalt();
                    var hash = security.SHA256(password + salt);

                    //Add the new user to the database
                    var insertQuery = `INSERT INTO users (username, firstName, lastName, email, salt, hashedPassword)
                                       VALUES ('${username}', '${firstName}', '${lastName}', '${email}', '${salt}', '${hash}')`;
                    connection.query(insertQuery, (error, result) => {
                        if (error) throw error;
                        console.log(`New user with username '${username}' successfullly added to database`);
                    });
                    res.redirect('/register'); //Head back to home page
                }
                //Go back if passwords don't match
                else {
                    res.redirect('/register');
                }
            }
        });
    }
});
// ------------------------------------------ //

// Leave the NodeJS web server listening on port 5000
var server = app.listen(5000, () => {
    var port = server.address().port;
    console.log('Server listening on port', port);
});